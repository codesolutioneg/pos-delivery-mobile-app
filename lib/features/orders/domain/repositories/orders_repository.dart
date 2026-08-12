import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/delivery_order_entity.dart';

abstract class OrdersRepository {
  Stream<Either<Failure, DeliveryOrderEntity?>> watchCurrentOrder({
    required String driverUid,
  });

  Stream<Either<Failure, List<DeliveryOrderEntity>>> watchAllOrders({
    required String driverUid,
  });

  Future<Either<Failure, void>> markDelivered({
    required String driverUid,
    required String orderId,
  });

  Future<Either<Failure, void>> updateStatus({
    required String driverUid,
    required String orderId,
    required String status,
  });
}
