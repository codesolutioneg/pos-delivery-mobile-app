/// Data-layer exception types (mapped to [Failure] in repositories).
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}
