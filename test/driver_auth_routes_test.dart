import 'dart:convert';
import 'dart:io';

import 'package:dishflow_delivery/core/config/app_config.dart';
import 'package:dishflow_delivery/core/network/driver_auth_routes.dart';
import 'package:flutter_test/flutter_test.dart';

String _apiRoot() => '${AppConfig.baseUrl}${AppConfig.apiPrefix}';

Uri _uri(String path) => Uri.parse('${_apiRoot()}$path');

Future<({int status, Map<String, dynamic> body})> _post(
  Uri uri, {
  required String restaurantKey,
  Map<String, dynamic>? json,
  String? bearer,
}) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(uri);
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('X-Restaurant-Key', restaurantKey);
    if (bearer != null) req.headers.set('Authorization', 'Bearer $bearer');
    req.add(utf8.encode(jsonEncode(json ?? {})));
    final res = await req.close();
    final text = await utf8.decodeStream(res);
    final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
    return (
      status: res.statusCode,
      body: decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'raw': decoded},
    );
  } finally {
    client.close();
  }
}

Future<({int status, Map<String, dynamic> body})> _get(
  Uri uri, {
  required String restaurantKey,
  String? bearer,
}) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set('X-Restaurant-Key', restaurantKey);
    if (bearer != null) req.headers.set('Authorization', 'Bearer $bearer');
    final res = await req.close();
    final text = await utf8.decodeStream(res);
    final decoded = text.isEmpty ? <String, dynamic>{} : jsonDecode(text);
    return (
      status: res.statusCode,
      body: decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'raw': decoded},
    );
  } finally {
    client.close();
  }
}

void main() {
  test('Flutter driver auth paths match DishFlow /api/v1/drivers/*', () {
    expect(AppConfig.apiPrefix, '/v1');
    expect(_apiRoot(), endsWith('/api/v1'));
    expect(DriverAuthRoutes.login, '/drivers/login');
    expect(DriverAuthRoutes.me, '/drivers/me');
    expect(DriverAuthRoutes.logout, '/drivers/logout');
    expect(_uri(DriverAuthRoutes.login).toString(),
        'https://api.dishflow.code-solution.org/api/v1/drivers/login');
    expect(_uri(DriverAuthRoutes.me).toString(),
        'https://api.dishflow.code-solution.org/api/v1/drivers/me');
    expect(_uri(DriverAuthRoutes.logout).toString(),
        'https://api.dishflow.code-solution.org/api/v1/drivers/logout');
  });

  test('live login / me / logout against DishFlow', () async {
    final user = Platform.environment['DRIVER_TEST_USER']?.trim() ?? '';
    final pass = Platform.environment['DRIVER_TEST_PASS'] ?? '';
    final key = Platform.environment['DRIVER_TEST_KEY']?.trim() ?? '';
    if (user.isEmpty || pass.isEmpty || key.isEmpty) {
      return;
    }

    final login = await _post(
      _uri(DriverAuthRoutes.login),
      restaurantKey: key,
      json: {'username': user, 'password': pass},
    );
    expect(login.status, 200, reason: '${login.body}');
    expect(login.body['success'], isTrue);
    final data = login.body['data'] as Map<String, dynamic>;
    final access = data['accessToken'] as String;
    final refresh = data['refreshToken'] as String;
    expect(access, isNotEmpty);
    expect(refresh, isNotEmpty);
    expect((data['driver'] as Map)['username'], user);

    final me = await _get(
      _uri(DriverAuthRoutes.me),
      restaurantKey: key,
      bearer: access,
    );
    expect(me.status, 200, reason: '${me.body}');
    expect((me.body['data'] as Map)['username'], user);

    final logout = await _post(
      _uri(DriverAuthRoutes.logout),
      restaurantKey: key,
      json: {'refreshToken': refresh},
    );
    expect(logout.status, 200, reason: '${logout.body}');
    expect(logout.body['success'], isTrue);
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('wrong restaurant key cannot log in that driver', () async {
    final user = Platform.environment['DRIVER_TEST_USER']?.trim() ?? '';
    final pass = Platform.environment['DRIVER_TEST_PASS'] ?? '';
    final wrongKey = Platform.environment['DRIVER_TEST_WRONG_KEY']?.trim() ?? '';
    if (user.isEmpty || pass.isEmpty || wrongKey.isEmpty) {
      return;
    }

    final login = await _post(
      _uri(DriverAuthRoutes.login),
      restaurantKey: wrongKey,
      json: {'username': user, 'password': pass},
    );
    expect(login.status, 401);
    expect(login.body['success'], isFalse);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
