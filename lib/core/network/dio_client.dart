import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Shared HTTP client for DishFlow driver APIs.
class DioClient {
  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.baseUrl}${AppConfig.apiPrefix}',
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'X-Restaurant-Key': AppConfig.restaurantKey,
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_secureStorage));
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  final FlutterSecureStorage _secureStorage;
  late final Dio _dio;

  Dio get client => _dio;
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  static const _retriableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isGet = options.method.toUpperCase() == 'GET';
    final attempt = (options.extra['retry_attempt'] as int?) ?? 0;

    if (isGet && _retriableTypes.contains(err.type) && attempt < AppConfig.maxRetries) {
      options.extra['retry_attempt'] = attempt + 1;
      try {
        final response = await _dio.fetch<dynamic>(options);
        handler.resolve(response);
        return;
      } catch (_) {
        // fall through
      }
    }
    handler.next(err);
  }
}
