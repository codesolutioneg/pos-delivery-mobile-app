import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../../domain/entities/delivery_order_line_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _orders(String driverUid) =>
      _db.collection('drivers').doc(driverUid).collection('orders');

  DeliveryOrderEntity _mapDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    // Prefer delivery_status — POS mirror may keep status as workflow stage.
    final rawStatus = (d['delivery_status'] ?? d['status'] ?? '').toString();
    final status = rawStatus.toLowerCase() == 'sale' &&
            (d['delivery_status']?.toString().isNotEmpty ?? false)
        ? d['delivery_status'].toString()
        : rawStatus;

    final items = d['items'];
    final lineItems = <DeliveryOrderLineEntity>[];
    var itemsSummary = '';
    double itemsSum = 0;
    if (items is List && items.isNotEmpty) {
      final parts = <String>[];
      for (final e in items) {
        if (e is! Map) continue;
        final name =
            (e['name'] ?? e['productName'] ?? e['product_name'] ?? '').toString();
        if (name.isEmpty) continue;
        final qtyNum = _asDouble(e['quantity'] ?? e['qty']) ?? 1;
        final qty = qtyNum.round().clamp(1, 9999);
        final lineTotal = _asDouble(
              e['total'] ?? e['totalPrice'] ?? e['total_price'],
            ) ??
            ((_asDouble(e['price'] ?? e['unitPrice'] ?? e['price_unit']) ?? 0) *
                qty);
        lineItems.add(
          DeliveryOrderLineEntity(
            name: name,
            quantity: qty,
            lineTotal: lineTotal > 0 ? lineTotal : null,
          ),
        );
        parts.add('$name x$qty');
        itemsSum += lineTotal;
      }
      itemsSummary = parts.join(', ');
    }

    final total = _asDouble(
          d['total_amount'] ??
              d['total'] ??
              d['amount'] ??
              d['grand_total'] ??
              d['totalAmount'],
        ) ??
        (itemsSum > 0 ? itemsSum : 0);

    return DeliveryOrderEntity(
      id: doc.id,
      status: status.isEmpty ? 'pending' : status,
      customerName:
          (d['customer_name'] ?? d['partnerName'] ?? 'Customer').toString(),
      customerPhone: (d['customer_phone'] ?? d['phone'] ?? '').toString(),
      address: _resolveCustomerAddress(d),
      itemsSummary: itemsSummary.isEmpty ? '—' : itemsSummary,
      items: lineItems,
      total: total,
      customerLat: (d['customer_lat'] as num?)?.toDouble() ??
          (d['customerLat'] as num?)?.toDouble(),
      customerLng: (d['customer_lng'] as num?)?.toDouble() ??
          (d['customerLng'] as num?)?.toDouble(),
      driverDeliveredAt: d['driverDeliveredAt'] != null
          ? DateTime.tryParse(d['driverDeliveredAt'].toString())
          : null,
      restaurantName: (d['branch_name'] ??
              d['restaurant_name'] ??
              d['vendor_name'] ??
              d['branchName'])
          ?.toString(),
      restaurantAddress: (d['branch_address'] ??
              d['restaurant_address'] ??
              d['vendor_location'])
          ?.toString(),
      otp: (d['otp'] ?? d['delivery_otp'] ?? d['confirmOtp'])?.toString(),
      orderNumber: (d['order_number'] ?? d['orderNumber'])?.toString(),
      odooOrderName: (d['odoo_order_name'] ??
              d['odooOrderName'] ??
              d['serverOrderName'])
          ?.toString(),
      odooOrderId: (d['odoo_order_id'] ?? d['odooOrderId'])?.toString(),
      displayOrderName:
          (d['display_order_name'] ?? d['displayOrderName'])?.toString(),
      paymentMethod: (d['payment_method'] ?? d['paymentMethod'])?.toString(),
      deliveryFee: _asDouble(d['delivery_fee'] ?? d['deliveryFee']),
    );
  }

  double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  /// Builds a single customer address line from POS mirror fields.
  String _resolveCustomerAddress(Map<String, dynamic> d) {
    final candidates = <String>[
      (d['customer_address'] ?? '').toString().trim(),
      (d['delivery_address'] ?? '').toString().trim(),
      (d['address'] ?? '').toString().trim(),
      (d['shipping_address'] ?? '').toString().trim(),
      (d['customerAddress'] ?? '').toString().trim(),
    ].where((s) => s.isNotEmpty).toList();

    final zone = (d['shipping_zone_name'] ??
            d['shippingZoneName'] ??
            d['delivery_area_name'] ??
            '')
        .toString()
        .trim();

    if (candidates.isEmpty) {
      return zone;
    }
    final primary = candidates.first;
    if (zone.isNotEmpty &&
        !primary.toLowerCase().contains(zone.toLowerCase())) {
      return '$primary — $zone';
    }
    return primary;
  }

  @override
  Stream<Either<Failure, DeliveryOrderEntity?>> watchCurrentOrder({
    required String driverUid,
  }) {
    return watchAllOrders(driverUid: driverUid).map((either) {
      return either.fold(Left.new, (orders) {
        for (final o in orders) {
          if (!o.isClosedOrRejected) return Right(o);
        }
        return const Right(null);
      });
    });
  }

  @override
  Stream<Either<Failure, List<DeliveryOrderEntity>>> watchAllOrders({
    required String driverUid,
  }) {
    return _orders(driverUid).snapshots().map((snap) {
      try {
        return Right<Failure, List<DeliveryOrderEntity>>(
          snap.docs.map(_mapDoc).toList(),
        );
      } catch (e) {
        return Left<Failure, List<DeliveryOrderEntity>>(
          ServerFailure(e.toString()),
        );
      }
    });
  }

  @override
  Future<Either<Failure, void>> markDelivered({
    required String driverUid,
    required String orderId,
  }) {
    return updateStatus(
      driverUid: driverUid,
      orderId: orderId,
      status: 'delivered',
    );
  }

  /// Reports the driver's stage on the customer's own order document.
  ///
  /// `ecommerce_orders/{id}` is the only document the customer app can find by
  /// id — it created it. Everything else in the POS pipeline
  /// (`suspended_orders`, `sales`) carries no link back to the store order, so
  /// without this the customer sees nothing move between "Received" and the
  /// cashier closing the sale.
  ///
  /// The id travels on the driver's own order document (`ecommerceOrderId`),
  /// written by the POS when the driver is assigned. A POS-rung delivery order
  /// has no such id and is skipped — nothing is created here.
  Future<void> _mirrorOntoStoreOrder({
    required String driverUid,
    required String orderId,
    required String status,
  }) async {
    const stages = <String, String>{
      'on_the_way': 'on_the_way',
      'picked_up': 'on_the_way',
      'in_transit': 'on_the_way',
      'shipped': 'on_the_way',
      'delivered': 'delivered',
      'driver_delivered': 'delivered',
    };
    final storeStatus = stages[status];
    if (storeStatus == null) return;

    try {
      final snap = await _orders(driverUid).doc(orderId).get();
      final ecommerceOrderId =
          (snap.data()?['ecommerceOrderId'] ?? '').toString().trim();
      if (ecommerceOrderId.isEmpty) return;

      // update(), never set(merge:true) — same rule as the sales write above:
      // this app reports on documents it did not create and must never invent
      // a store order.
      await _db.collection('ecommerce_orders').doc(ecommerceOrderId).update({
        'status': storeStatus,
        'statusUpdatedAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Non-fatal: not a store order, doc gone, or rules block the write. The
      // driver's own status change already succeeded.
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus({
    required String driverUid,
    required String orderId,
    required String status,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final data = <String, dynamic>{
        'delivery_status': status,
        'status': status,
        'updatedAt': now,
      };
      if (status == 'delivered' || status == 'driver_delivered') {
        data['driverDeliveredAt'] = now;
      }
      await _orders(driverUid).doc(orderId).set(data, SetOptions(merge: true));

      // Mirror onto sales so the POS delivery board reflects driver actions.
      // Doc id under drivers/.../orders is the sale doc id.
      //
      // MUST be update(), never set(merge:true): a driver can be assigned an
      // order while it is still suspended in the POS, i.e. before any sale
      // exists. set(merge:true) would CREATE `sales/{id}` as a stub holding
      // only a delivery_status — and the POS collision guard
      // (SaleDocId.isSameOrder) reads that stub as "a different order",
      // so checkout would then file the real sale under a collision-safe id.
      // update() throws on a missing doc and is swallowed below, which is
      // exactly the wanted behaviour: touch the sale only once it is real.
      try {
        await _db.collection('sales').doc(orderId).update({
          'delivery_status': status,
          'updatedAt': now,
          if (status == 'delivered') 'driverDeliveredAt': now,
        });
      } catch (_) {
        // Non-fatal: no sale yet, different doc id, or rules block the write.
      }

      await _mirrorOntoStoreOrder(
        driverUid: driverUid,
        orderId: orderId,
        status: status,
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firestore write failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
