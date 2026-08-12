import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/tracking_repository.dart';

/// Writes live GPS to Firestore `driver_locations/{driverUid}` so the
/// customer ecommerce app can show the rider on the track-order map.
class FirestoreTrackingRepository implements TrackingRepository {
  FirestoreTrackingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  StreamSubscription<Position>? _sub;
  bool _running = false;

  bool get isRunning => _running;

  @override
  Future<Either<Failure, void>> start({required String driverUid}) async {
    await stop();
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const Left(ServerFailure('Location permission denied'));
    }
    _running = true;
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 12,
      ),
    ).listen((pos) {
      unawaited(_write(driverUid, pos));
    });
    try {
      final current = await Geolocator.getCurrentPosition();
      await _write(driverUid, current);
    } catch (_) {}
    return const Right(null);
  }

  Future<void> _write(String driverUid, Position pos) async {
    await _db.collection('driver_locations').doc(driverUid).set(
      {
        'lat': pos.latitude,
        'lng': pos.longitude,
        'heading': pos.heading,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<Either<Failure, void>> stop() async {
    await _sub?.cancel();
    _sub = null;
    _running = false;
    return const Right(null);
  }
}
