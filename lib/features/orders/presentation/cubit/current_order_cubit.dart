import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import 'current_order_state.dart';

/// Watches all active driver orders (multi-order Home).
class CurrentOrderCubit extends Cubit<CurrentOrderState> {
  CurrentOrderCubit(this._repository) : super(const CurrentOrderInitial());

  final OrdersRepository _repository;
  StreamSubscription<Either<Failure, List<DeliveryOrderEntity>>>? _subscription;
  String? _driverUid;
  String? _selectedId;

  void watch({required String driverUid}) {
    _driverUid = driverUid;
    emit(const CurrentOrderLoading());
    _subscription?.cancel();
    _subscription = _repository.watchAllOrders(driverUid: driverUid).listen(
      (either) {
        either.fold(
          (failure) => emit(CurrentOrderFailure(failure.message)),
          (all) {
            final active =
                all.where((o) => !o.isClosedOrRejected).toList(growable: false);
            if (active.isEmpty) {
              _selectedId = null;
              emit(const CurrentOrderEmpty());
              return;
            }
            final stillValid =
                _selectedId != null && active.any((o) => o.id == _selectedId);
            _selectedId = stillValid ? _selectedId : active.first.id;
            emit(
              CurrentOrderLoaded(
                orders: active,
                selectedId: _selectedId!,
              ),
            );
          },
        );
      },
      onError: (Object e) => emit(CurrentOrderFailure(e.toString())),
    );
  }

  void selectOrder(String orderId) {
    final current = state;
    if (current is! CurrentOrderLoaded) return;
    if (!current.orders.any((o) => o.id == orderId)) return;
    _selectedId = orderId;
    emit(
      CurrentOrderLoaded(
        orders: current.orders,
        selectedId: orderId,
      ),
    );
  }

  Future<void> markDelivered({String? orderId}) async {
    final current = state;
    final driverUid = _driverUid;
    if (current is! CurrentOrderLoaded || driverUid == null) return;
    final id = orderId ?? current.selectedId;
    final result = await _repository.markDelivered(
      driverUid: driverUid,
      orderId: id,
    );
    result.fold(
      (failure) => emit(CurrentOrderFailure(failure.message)),
      (_) {},
    );
  }

  Future<void> updateStatus(String status, {String? orderId}) async {
    final current = state;
    final driverUid = _driverUid;
    if (current is! CurrentOrderLoaded || driverUid == null) return;
    final id = orderId ?? current.selectedId;
    final result = await _repository.updateStatus(
      driverUid: driverUid,
      orderId: id,
      status: status,
    );
    result.fold(
      (failure) => emit(CurrentOrderFailure(failure.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
