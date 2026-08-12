import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class StubOrdersRepository implements OrdersRepository {
  @override
  Stream<Either<Failure, DeliveryOrderEntity?>> watchCurrentOrder({
    required String driverUid,
  }) =>
      Stream.value(const Right(null));

  @override
  Stream<Either<Failure, List<DeliveryOrderEntity>>> watchAllOrders({
    required String driverUid,
  }) =>
      Stream.value(const Right([]));

  @override
  Future<Either<Failure, void>> markDelivered({
    required String driverUid,
    required String orderId,
  }) async =>
      const Left(ServerFailure('Stub'));

  @override
  Future<Either<Failure, void>> updateStatus({
    required String driverUid,
    required String orderId,
    required String status,
  }) async =>
      const Left(ServerFailure('Stub'));
}
