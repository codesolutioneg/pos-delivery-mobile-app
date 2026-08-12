import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/tracking_repository.dart';

/// Scaffold stub — real Geolocator + RTDB writer comes next.
class StubTrackingRepository implements TrackingRepository {
  bool _running = false;

  bool get isRunning => _running;

  @override
  Future<Either<Failure, void>> start({required String driverUid}) async {
    _running = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> stop() async {
    _running = false;
    return const Right(null);
  }
}
