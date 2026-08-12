import 'package:equatable/equatable.dart';

/// One line item on a delivery order.
class DeliveryOrderLineEntity extends Equatable {
  const DeliveryOrderLineEntity({
    required this.name,
    required this.quantity,
    this.lineTotal,
  });

  final String name;
  final int quantity;
  final double? lineTotal;

  String get label => '$name x$quantity';

  @override
  List<Object?> get props => [name, quantity, lineTotal];
}
