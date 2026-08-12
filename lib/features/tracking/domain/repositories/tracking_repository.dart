import '../../../../core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Broadcasts driver GPS to RTDB `driver_locations/{driverUid}`.
abstract class TrackingRepository {
  Future<Either<Failure, void>> start({required String driverUid});

  Future<Either<Failure, void>> stop();
}
