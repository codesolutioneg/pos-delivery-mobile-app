import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/driver_rounded_button.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../cubit/current_order_cubit.dart';
import '../utils/order_ui_utils.dart';
import '../widgets/order_items_card.dart';
import '../widgets/order_route_timeline.dart';

class PickupOrderPage extends StatelessWidget {
  const PickupOrderPage({super.key, required this.order});

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

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: Text(l10n.orderNumber(order.displayId))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Center(
            child: Image.asset(
              'assets/images/order_pickup.gif',
              height: 160,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColors.brandPrimary,
              ),
            ),
          ),
          Text(l10n.pickupTitle, style: AppTextStyles.titleLg()),
          const SizedBox(height: 6),
          Text(l10n.pickupSubtitle, style: AppTextStyles.bodyMd()),
          const SizedBox(height: 20),
          Text(l10n.pickupRoute, style: AppTextStyles.label()),
          const SizedBox(height: 10),
          _card(
            child: OrderRouteTimeline(
              restaurantTitle: restaurant,
              restaurantAddress: restAddr,
              customerTitle: l10n.deliverTo,
              customerAddress: order.address.isNotEmpty
                  ? order.address
                  : l10n.addressMissing,
              restaurantOnly: false,
              showBoth: true,
              onCustomerCall: () =>
                  launchPhoneCall(context, order.customerPhone),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            child: Column(
              children: [
                _kv(l10n.customer, order.customerName),
                _kv(l10n.phone, order.customerPhone),
                _kv(
                  l10n.address,
                  order.address.isNotEmpty
                      ? order.address
                      : l10n.addressMissing,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OrderItemsCard(order: order),
          const SizedBox(height: 24),
          DriverRoundedButton(
            title: l10n.pickedUpStartDelivery,
            color: AppColors.driverApp300,
            onPressed: () async {
              await context.read<CurrentOrderCubit>().updateStatus('on_the_way');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.statusUpdatedOnTheWay)),
                );
                context.push(AppRoutes.deliver, extra: order);
              }
            },
          ),

        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 88, child: Text(k, style: AppTextStyles.bodySm())),
          Expanded(
            child: Text(v, style: AppTextStyles.bodyMd(color: AppColors.grey800)),
          ),
        ],
      ),
    );
  }
}
