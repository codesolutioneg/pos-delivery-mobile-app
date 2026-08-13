import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'restaurant_key_interceptor.dart';
import 'restaurant_key_provider.dart';

/// Shared HTTP client for DishFlow driver APIs.
class DioClient {
  DioClient(this._secureStorage, {RestaurantKeyProvider? restaurantKeyProvider})
      : restaurantKeys = restaurantKeyProvider ?? RestaurantKeyProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.baseUrl}${AppConfig.apiPrefix}',
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Resolved per request, not baked into BaseOptions: the branch — and so the
    // restaurant — is picked at runtime, so a compile-time key can belong to a
    // different restaurant and turn every login into "Invalid username or
    // password". Must run before AuthInterceptor so a retry keeps both headers.
    _dio.interceptors.add(RestaurantKeyInterceptor(restaurantKeys, _dio));
    _dio.interceptors.add(AuthInterceptor(_secureStorage));
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  final FlutterSecureStorage _secureStorage;

  /// Exposed so the UI can show which restaurant the branch resolved to.
  final RestaurantKeyProvider restaurantKeys;

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
