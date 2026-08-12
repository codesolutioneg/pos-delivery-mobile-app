import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_order_entity.dart';

sealed class OrdersListState extends Equatable {
  const OrdersListState();

  @override
  List<Object?> get props => [];
}

final class OrdersListInitial extends OrdersListState {
  const OrdersListInitial();
}

final class OrdersListLoading extends OrdersListState {
  const OrdersListLoading();
}

final class OrdersListLoaded extends OrdersListState {
  const OrdersListLoaded({
    required this.active,
    required this.completed,
  });

  final List<DeliveryOrderEntity> active;
  final List<DeliveryOrderEntity> completed;

  @override
  List<Object?> get props => [active, completed];
}

final class OrdersListFailure extends OrdersListState {
  const OrdersListFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
