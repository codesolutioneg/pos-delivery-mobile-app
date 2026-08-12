import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/driver_rounded_button.dart';
import '../../../../core/widgets/my_separator.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../cubit/current_order_cubit.dart';
import '../utils/order_ui_utils.dart';
import 'order_route_timeline.dart';

/// Bottom sheet body for current active / pending order.
class ActiveOrderSheet extends StatelessWidget {
  const ActiveOrderSheet({super.key, required this.order});

  final DeliveryOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final restaurant = order.restaurantName?.isNotEmpty == true
        ? order.restaurantName!
        : l10n.restaurantFallback;
    final restAddr = order.restaurantAddress?.isNotEmpty == true
        ? order.restaurantAddress!
        : l10n.pickupLocationFallback;

    if (order.isPending) {
      return _PendingBody(
        order: order,
        restaurant: restaurant,
        restAddr: restAddr,
      );
    }
    return _ActiveBody(
      order: order,
      restaurant: restaurant,
      restAddr: restAddr,
    );
  }
}

class _PendingBody extends StatefulWidget {
  const _PendingBody({
    required this.order,
    required this.restaurant,
    required this.restAddr,
  });

  final DeliveryOrderEntity order;
  final String restaurant;
  final String restAddr;

  @override
  State<_PendingBody> createState() => _PendingBodyState();
}

class _PendingBodyState extends State<_PendingBody> {
  static const int _seconds = 60;
  int _left = _seconds;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_left <= 1) {
        context.read<CurrentOrderCubit>().updateStatus('driver_rejected');
        return;
      }
      setState(() => _left -= 1);
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = widget.order;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(l10n.newOrder, style: AppTextStyles.titleMd()),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.autoRejectSeconds(_left),
                style: AppTextStyles.bodySm(color: AppColors.grey800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OrderRouteTimeline(
          restaurantTitle: widget.restaurant,
          restaurantAddress: widget.restAddr,
          customerTitle: l10n.deliverTo,
          customerAddress: order.address,
          onCustomerCall: () => launchPhoneCall(context, order.customerPhone),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: MySeparator(),
        ),
        _info(l10n.customer, order.customerName),
        _info(l10n.items, order.itemsSummary),
        _info(l10n.total, order.total.toStringAsFixed(2)),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: DriverRoundedButton(
                title: l10n.reject,
                color: AppColors.error,
                onPressed: () => context
                    .read<CurrentOrderCubit>()
                    .updateStatus('driver_rejected'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DriverRoundedButton(
                title: l10n.accept,
                color: AppColors.success,
                onPressed: () =>
                    context.read<CurrentOrderCubit>().updateStatus('accepted'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _info(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(k, style: AppTextStyles.bodySm())),
          Expanded(
            child: Text(v, style: AppTextStyles.bodyMd(color: AppColors.grey800)),
          ),
        ],
      ),
    );
  }
}

class _ActiveBody extends StatelessWidget {
  const _ActiveBody({
    required this.order,
    required this.restaurant,
    required this.restAddr,
  });

  final DeliveryOrderEntity order;
  final String restaurant;
  final String restAddr;

  String _cta(AppLocalizations l10n) {
    if (order.isDeliveredMarked) return l10n.ctaWaitingCashier;
    if (order.isPickedUp) return l10n.ctaReachedCustomer;
    return l10n.ctaReachedRestaurant;
  }

  void _onCta(BuildContext context) {
    if (order.isDeliveredMarked) return;
    if (order.isPickedUp) {
      context.push(AppRoutes.deliver, extra: order);
      return;
    }
    context.push(AppRoutes.pickup, extra: order);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customerAddress =
        order.address.isNotEmpty ? order.address : l10n.addressMissing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.orderNumber(order.displayId),
          style: AppTextStyles.bodySm(color: AppColors.brandPrimary),
        ),
        const SizedBox(height: 8),
        OrderRouteTimeline(
          restaurantTitle: restaurant,
          restaurantAddress: restAddr,
          customerTitle: order.customerName,
          customerAddress: customerAddress,
          restaurantOnly: false,
          showBoth: true,
          onCustomerCall: () => launchPhoneCall(context, order.customerPhone),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: MySeparator(),
        ),
        _info(l10n.status, order.status),
        _info(
          l10n.phone,
          order.customerPhone.isEmpty ? '—' : order.customerPhone,
        ),
        _info(l10n.address, customerAddress),
        _info(l10n.items, order.itemsSummary),
        _info(
          l10n.payment,
          order.paymentLabelLocalized(
            cashLabel: l10n.paymentCash,
            emptyLabel: l10n.paymentDash,
          ),
        ),
        if (order.deliveryFee != null && order.deliveryFee! > 0)
          _info(l10n.deliveryFee, order.deliveryFee!.toStringAsFixed(2)),
        _info(l10n.collect, order.total.toStringAsFixed(2)),
        const SizedBox(height: 18),
        DriverRoundedButton(
          title: _cta(l10n),
          color: AppColors.driverApp300,
          enabled: !order.isDeliveredMarked,
          onPressed: () => _onCta(context),
        ),
      ],
    );
  }

  Widget _info(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(k, style: AppTextStyles.bodySm())),
          Expanded(
            child: Text(v, style: AppTextStyles.bodyMd(color: AppColors.grey800)),
          ),
        ],
      ),
    );
  }
}
