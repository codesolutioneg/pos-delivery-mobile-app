import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dishflow_delivery/core/config/app_config.dart';
import 'package:dishflow_delivery/core/network/restaurant_key_interceptor.dart';
import 'package:dishflow_delivery/core/network/restaurant_key_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records every request and answers from a scripted queue — no network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;
  final List<RequestOptions> calls = <RequestOptions>[];

  /// Header **snapshots**. A retry mutates the same `RequestOptions` instance,
  /// so holding the reference would show the retried value on the first call
  /// and hide the very thing these tests assert.
  final List<Map<String, dynamic>> sentHeaders = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    sentHeaders.add(Map<String, dynamic>.from(options.headers));
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Map<String, dynamic> body, int status) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  RestaurantKeyProvider providerFor(
    _FakeAdapter adapter, {
    String projectId = 'odc-chat',
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: '${AppConfig.baseUrl}${AppConfig.apiPrefix}',
      validateStatus: (_) => true,
    ))
      ..httpClientAdapter = adapter;
    return RestaurantKeyProvider(
      dio: dio,
      projectIdResolver: () => projectId,
    );
  }

  group('RestaurantKeyProvider', () {
    test('resolves the key for the active Firebase project', () async {
      final adapter = _FakeAdapter((_) => _json({
            'success': true,
            'data': {
              'apiKey': 'dk_dev_key',
              'restaurantName': 'Dev',
            },
          }, 200));

      final key = await providerFor(adapter).resolve();

      expect(key, 'dk_dev_key');
      expect(adapter.calls.single.path, contains('/tenant/firebase-key'));
      expect(
        adapter.calls.single.data,
        containsPair('firebaseProjectId', 'odc-chat'),
      );
    });

    test('caches so a second call does not hit the rate-limited endpoint',
        () async {
      final adapter = _FakeAdapter((_) => _json({
            'success': true,
            'data': {'apiKey': 'dk_dev_key', 'restaurantName': 'Dev'},
          }, 200));
      final provider = providerFor(adapter);

      await provider.resolve();
      await provider.resolve();

      expect(adapter.calls, hasLength(1));
    });

    test('two branches never share a key', () async {
      final adapter = _FakeAdapter((options) {
        final id = (options.data as Map)['firebaseProjectId'];
        return _json({
          'success': true,
          'data': {
            'apiKey': id == 'odc-chat' ? 'dk_dev_key' : 'dk_balkans_key',
            'restaurantName': id == 'odc-chat' ? 'Dev' : 'Balkans',
          },
        }, 200);
      });

      final dev = await providerFor(adapter, projectId: 'odc-chat').resolve();
      final balkans =
          await providerFor(adapter, projectId: 'pos-test-70970').resolve();

      expect(dev, 'dk_dev_key');
      expect(balkans, 'dk_balkans_key');
    });

    test('falls back to the compile-time key when the branch is unregistered',
        () async {
      final adapter = _FakeAdapter((_) => _json({
            'success': false,
            'error': {
              'code': 'RESTAURANT_NOT_FOUND',
              'message': 'no restaurant',
            },
          }, 404));

      final key = await providerFor(adapter).resolve();

      expect(key, AppConfig.restaurantKey);
    });

    test('invalidate() forces a fresh fetch', () async {
      var served = 0;
      final adapter = _FakeAdapter((_) {
        served++;
        return _json({
          'success': true,
          'data': {'apiKey': 'dk_v$served', 'restaurantName': 'Dev'},
        }, 200);
      });
      final provider = providerFor(adapter);

      expect(await provider.resolve(), 'dk_v1');
      await provider.invalidate();
      expect(await provider.resolve(), 'dk_v2');
    });
  });

  group('RestaurantKeyInterceptor', () {
    test('stamps the resolved key on every request', () async {
      final keyAdapter = _FakeAdapter((_) => _json({
            'success': true,
            'data': {'apiKey': 'dk_dev_key', 'restaurantName': 'Dev'},
          }, 200));
      final provider = providerFor(keyAdapter);

      final apiAdapter = _FakeAdapter((_) => _json({'success': true}, 200));
      final dio = Dio(BaseOptions(baseUrl: 'https://x/api/v1'))
        ..httpClientAdapter = apiAdapter;
      dio.interceptors.add(RestaurantKeyInterceptor(provider, dio));

      await dio.post<dynamic>('/drivers/login', data: {'username': 'a'});

      expect(
        apiAdapter.sentHeaders.single['X-Restaurant-Key'],
        'dk_dev_key',
      );
    });

    test('retries once with a fresh key on RESTAURANT_KEY_INVALID', () async {
      var served = 0;
      final keyAdapter = _FakeAdapter((_) {
        served++;
        return _json({
          'success': true,
          'data': {'apiKey': 'dk_v$served', 'restaurantName': 'Dev'},
        }, 200);
      });
      final provider = providerFor(keyAdapter);

      final apiAdapter = _FakeAdapter((options) {
        final sent = options.headers['X-Restaurant-Key'];
        if (sent == 'dk_v1') {
          return _json({
            'success': false,
            'error': {
              'code': 'RESTAURANT_KEY_INVALID',
              'message': 'stale',
            },
          }, 401);
        }
        return _json({'success': true, 'data': {}}, 200);
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://x/api/v1'))
        ..httpClientAdapter = apiAdapter;
      dio.interceptors.add(RestaurantKeyInterceptor(provider, dio));

      final res = await dio.post<dynamic>('/drivers/login', data: {});

      expect(res.statusCode, 200);
      expect(apiAdapter.calls, hasLength(2));
      expect(apiAdapter.sentHeaders.first['X-Restaurant-Key'], 'dk_v1');
      expect(apiAdapter.sentHeaders.last['X-Restaurant-Key'], 'dk_v2');
    });

    test('never keys the public /tenant/firebase-key call', () async {
      final keyAdapter = _FakeAdapter((_) => _json({
            'success': true,
            'data': {'apiKey': 'dk_dev_key', 'restaurantName': 'Dev'},
          }, 200));
      final provider = providerFor(keyAdapter);

      final apiAdapter = _FakeAdapter((_) => _json({'success': true}, 200));
      final dio = Dio(BaseOptions(baseUrl: 'https://x/api/v1'))
        ..httpClientAdapter = apiAdapter;
      dio.interceptors.add(RestaurantKeyInterceptor(provider, dio));

      await dio.post<dynamic>('/tenant/firebase-key', data: {});

      expect(
        apiAdapter.sentHeaders.single.containsKey('X-Restaurant-Key'),
        isFalse,
      );
    });
  });
}
