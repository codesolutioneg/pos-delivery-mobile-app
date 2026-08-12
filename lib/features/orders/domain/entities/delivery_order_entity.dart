import 'package:equatable/equatable.dart';

import '../utils/order_display_id.dart';
import 'delivery_order_line_entity.dart';

/// Driver-facing order (from POS mirror `drivers/{id}/orders`).
class DeliveryOrderEntity extends Equatable {
  const DeliveryOrderEntity({
    required this.id,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.itemsSummary,
    required this.total,
    this.items = const [],
    this.customerLat,
    this.customerLng,
    this.driverDeliveredAt,
    this.restaurantName,
    this.restaurantAddress,
    this.otp,
    this.orderNumber,
    this.odooOrderName,
    this.odooOrderId,
    this.displayOrderName,
    this.paymentMethod,
    this.deliveryFee,
  });

  final String id;
  final String status;
  final String customerName;
  final String customerPhone;
  final String address;
  final String itemsSummary;
  final List<DeliveryOrderLineEntity> items;
  final double total;
  final double? customerLat;
  final double? customerLng;
  final DateTime? driverDeliveredAt;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? otp;
  final String? orderNumber;
  final String? odooOrderName;
  final String? odooOrderId;
  final String? displayOrderName;
  final String? paymentMethod;
  final double? deliveryFee;

  String get _s => status.toLowerCase().trim();

  bool get isDeliveredMarked {
    return driverDeliveredAt != null ||
        _s == 'delivered' ||
        _s == 'driver_delivered' ||
        _s == 'completed' ||
        _s == 'done' ||
        _s == 'order completed';
  }

  bool get isClosedOrRejected {
    return isDeliveredMarked ||
        _s.contains('reject') ||
        _s.contains('cancel');
  }

  bool get isPending {
    return _s == 'pending' ||
        _s == 'driver pending' ||
        _s == 'driver_pending' ||
        _s == 'new';
  }

  bool get isAccepted {
    return _s == 'received' ||
        _s == 'accepted' ||
        _s == 'assigned' ||
        _s == 'sent' ||
        _s == 'driver accepted' ||
        _s == 'driver_accepted' ||
        _s == 'out_for_delivery';
  }

  bool get isPickedUp {
    return _s == 'on_the_way' ||
        _s == 'on-way' ||
        _s == 'picked_up' ||
        _s == 'in_transit' ||
        _s == 'in transit' ||
        _s == 'order shipped' ||
        _s == 'shipped';
  }

  /// Same label cashiers see on POS / receipt (e.g. `#34792`).
  String get displayId => OrderDisplayId.resolve(
        docId: id,
        displayOrderName: displayOrderName,
        orderNumber: orderNumber,
        odooOrderName: odooOrderName,
        odooOrderId: odooOrderId,
      );

  String paymentLabelLocalized({
    required String cashLabel,
    required String emptyLabel,
  }) {
    final p = (paymentMethod ?? '').toLowerCase();
    if (p.isEmpty) return emptyLabel;
    if (p.contains('cash') || p == 'pay_on_site') return cashLabel;
    return paymentMethod!;
  }

  @override
  List<Object?> get props => [
        id,
        status,
        customerName,
        customerPhone,
        address,
        itemsSummary,
        items,
        total,
        customerLat,
        customerLng,
        driverDeliveredAt,
        restaurantName,
        restaurantAddress,
        otp,
        orderNumber,
        odooOrderName,
        odooOrderId,
        displayOrderName,
        paymentMethod,
        deliveryFee,
      ];
}
