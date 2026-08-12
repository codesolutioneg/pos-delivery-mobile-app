import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_list_state.dart';

class OrdersListCubit extends Cubit<OrdersListState> {
  OrdersListCubit(this._repository) : super(const OrdersListInitial());

  final OrdersRepository _repository;
  StreamSubscription<Either<Failure, List<DeliveryOrderEntity>>>? _sub;

  static const _closed = {
    'completed',
    'delivered',
    'driver_delivered',
    'cancelled',
    'canceled',
  };

  void watch({required String driverUid}) {
    emit(const OrdersListLoading());
    _sub?.cancel();
    _sub = _repository.watchAllOrders(driverUid: driverUid).listen((either) {
      either.fold(
        (f) => emit(OrdersListFailure(f.message)),
        (orders) {
          final active = <DeliveryOrderEntity>[];
          final completed = <DeliveryOrderEntity>[];
          for (final o in orders) {
            final closed = o.isClosedOrRejected ||
                _closed.contains(o.status.toLowerCase());
            if (closed) {
              completed.add(o);
            } else {
              active.add(o);
            }
          }
          emit(OrdersListLoaded(active: active, completed: completed));
        },
      );
    }, onError: (Object e) => emit(OrdersListFailure(e.toString())));
  }

  Future<void> markDelivered({
    required String driverUid,
    required String orderId,
  }) async {
    final result = await _repository.markDelivered(
      driverUid: driverUid,
      orderId: orderId,
    );
    result.fold(
      (f) => emit(OrdersListFailure(f.message)),
      (_) {},
    );
  }

  Future<void> updateStatus({
    required String driverUid,
    required String orderId,
    required String status,
  }) async {
    final result = await _repository.updateStatus(
      driverUid: driverUid,
      orderId: orderId,
      status: status,
    );
    result.fold(
      (f) => emit(OrdersListFailure(f.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
