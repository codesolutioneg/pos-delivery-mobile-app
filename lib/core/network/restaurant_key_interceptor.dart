import 'package:dio/dio.dart';

import 'restaurant_key_provider.dart';

/// Puts the branch's `X-Restaurant-Key` on every request, resolved at runtime.
///
/// The header cannot be a static `BaseOptions` value: the branch (and therefore
/// the restaurant) is chosen after the client is built, so a baked key can point
/// at a different restaurant than the Firebase project in use.
///
/// On `RESTAURANT_KEY_INVALID` the cached key is dropped and the request is
/// retried **once** with a freshly resolved one — that covers a rotated key
/// without making the driver log in again.
class RestaurantKeyInterceptor extends Interceptor {
  RestaurantKeyInterceptor(this._provider, this._dio);

  final RestaurantKeyProvider _provider;
  final Dio _dio;

  static const _retriedFlag = 'restaurant_key_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // The key-resolving endpoint itself is public — never key it.
    if (options.path.contains('/tenant/firebase-key')) {
      handler.next(options);
      return;
    }
    options.headers['X-Restaurant-Key'] = await _provider.resolve();
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra[_retriedFlag] == true;

    if (!alreadyRetried && _isInvalidKey(err)) {
      await _provider.invalidate();
      final fresh = await _provider.resolve(forceRefresh: true);
      options.extra[_retriedFlag] = true;
      options.headers['X-Restaurant-Key'] = fresh;
      try {
        handler.resolve(await _dio.fetch<dynamic>(options));
        return;
      } catch (_) {
        // Fall through to the original error.
      }
    }
    handler.next(err);
  }

  bool _isInvalidKey(DioException err) {
    if (err.response?.statusCode != 401) return false;
    final data = err.response?.data;
    if (data is! Map) return false;
    final code = ((data['error'] as Map?)?['code'] ?? '').toString();
    return code == 'RESTAURANT_KEY_INVALID';
  }
}
