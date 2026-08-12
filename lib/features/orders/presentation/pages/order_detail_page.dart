import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/driver_rounded_button.dart';
import '../../../../core/widgets/my_separator.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../cubit/orders_list_cubit.dart';
import '../utils/order_ui_utils.dart';
import '../widgets/order_route_timeline.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final DeliveryOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final restaurant = order.restaurantName?.isNotEmpty == true
        ? order.restaurantName!
        : l10n.restaurantFallback;
    final restAddr = order.restaurantAddress?.isNotEmpty == true
        ? order.restaurantAddress!
        : '—';
    final chipColor = statusColor(order.status);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: Text(l10n.orderNumber(order.displayId))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.customerName,
                        style: AppTextStyles.titleMd(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: AppTextStyles.bodySm(color: chipColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                OrderRouteTimeline(
                  restaurantTitle: restaurant,
                  restaurantAddress: restAddr,
                  customerTitle: l10n.deliverTo,
                  customerAddress: order.address,
                  onCustomerCall: () =>
                      launchPhoneCall(context, order.customerPhone),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: MySeparator(),
                ),
                _row(l10n.phone, order.customerPhone),
                _row(l10n.items, order.itemsSummary),
                _row(
                  l10n.payment,
                  order.paymentLabelLocalized(
                    cashLabel: l10n.paymentCash,
                    emptyLabel: l10n.paymentDash,
                  ),
                ),
                if (order.deliveryFee != null && order.deliveryFee! > 0)
                  _row(l10n.deliveryFee, order.deliveryFee!.toStringAsFixed(2)),
                _row(l10n.total, order.total.toStringAsFixed(2)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!order.isDeliveredMarked && !order.isClosedOrRejected) ...[
            if (order.isPickedUp)
              DriverRoundedButton(
                title: l10n.markDelivered,
                color: AppColors.driverApp300,
                onPressed: () => _markDelivered(context),
              )
            else
              DriverRoundedButton(
                title: l10n.goToPickup,
                color: AppColors.driverApp300,
                onPressed: () async {
                  final auth = context.read<AuthCubit>().state;
                  if (auth is AuthAuthenticated) {
                    await context.read<OrdersListCubit>().updateStatus(
                          driverUid: auth.driver.id,
                          orderId: order.id,
                          status: 'on_the_way',
                        );
                  }
                  if (context.mounted) {
                    context.push(AppRoutes.deliver, extra: order);
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _markDelivered(BuildContext context) async {
    final auth = context.read<AuthCubit>().state;
    if (auth is! AuthAuthenticated) return;
    await context.read<OrdersListCubit>().markDelivered(
          driverUid: auth.driver.id,
          orderId: order.id,
        );
    if (context.mounted) Navigator.of(context).pop();
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(k, style: AppTextStyles.bodySm())),
          Expanded(
            child: Text(
              v.isEmpty ? '—' : v,
              style: AppTextStyles.bodyMd(color: AppColors.grey800),
            ),
          ),
        ],
      ),
    );
  }
}
