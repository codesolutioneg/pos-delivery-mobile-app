import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_order_entity.dart';

sealed class CurrentOrderState extends Equatable {
  const CurrentOrderState();

  @override
  List<Object?> get props => [];
}

final class CurrentOrderInitial extends CurrentOrderState {
  const CurrentOrderInitial();
}

final class CurrentOrderLoading extends CurrentOrderState {
  const CurrentOrderLoading();
}

final class CurrentOrderEmpty extends CurrentOrderState {
  const CurrentOrderEmpty();
}

/// One or more active orders — UI shows [selected] with a switcher for the rest.
final class CurrentOrderLoaded extends CurrentOrderState {
  const CurrentOrderLoaded({
    required this.orders,
    required this.selectedId,
  });

  final List<DeliveryOrderEntity> orders;
  final String selectedId;

  DeliveryOrderEntity get selected {
    for (final o in orders) {
      if (o.id == selectedId) return o;
    }
    return orders.first;
  }

  @override
  List<Object?> get props => [orders, selectedId];
}

final class CurrentOrderFailure extends CurrentOrderState {
  const CurrentOrderFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
