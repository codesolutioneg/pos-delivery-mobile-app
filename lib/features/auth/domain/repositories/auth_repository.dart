import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/driver_entity.dart';

/// Auth contract for driver login / session.
abstract class AuthRepository {
  Future<Either<Failure, DriverEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, DriverEntity?>> restoreSession();

  Future<Either<Failure, void>> logout();
}
