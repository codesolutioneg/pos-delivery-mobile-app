import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

/// Logs the driver in with username/password.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, DriverEntity>> call({
    required String username,
    required String password,
  }) {
    if (username.trim().isEmpty || password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Username and password are required')),
      );
    }
    return _repository.login(username: username.trim(), password: password);
  }
}
