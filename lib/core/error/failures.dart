/// Domain-level failure types.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error']);
}
