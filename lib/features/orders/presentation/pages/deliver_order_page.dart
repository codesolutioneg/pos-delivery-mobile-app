import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class DeliverOrderPage extends StatelessWidget {
  const DeliverOrderPage({super.key, required this.order});

  final DeliveryOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: Text(l10n.orderNumber(order.displayId))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.deliverTo, style: AppTextStyles.titleMd()),
                      const SizedBox(height: 4),
                      Text(order.customerName, style: AppTextStyles.bodyMd()),
                      Text(
                        order.address.isNotEmpty
                            ? order.address
                            : l10n.addressMissing,
                        style: AppTextStyles.bodySm(),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.customerPhone.isNotEmpty
                            ? order.customerPhone
                            : '—',
                        style: AppTextStyles.bodySm(),
                      ),
                    ],
                  ),
                ),
                _roundIcon(
                  asset: 'assets/icons/ic_wechat.svg',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.chatComingSoon)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _roundIcon(
                  asset: 'assets/icons/ic_phone_call.svg',
                  onTap: () => launchPhoneCall(context, order.customerPhone),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OrderItemsCard(order: order),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.payment, style: AppTextStyles.bodySm()),
                ),
                Text(
                  order.paymentLabelLocalized(
                    cashLabel: l10n.paymentCash,
                    emptyLabel: l10n.paymentDash,
                  ),
                  style: AppTextStyles.bodyMd(color: AppColors.grey800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          DriverRoundedButton(
            title: l10n.markDelivered,
            color: AppColors.driverApp300,
            onPressed: () async {
              await context.read<CurrentOrderCubit>().markDelivered();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.markedDelivered)),
                );
                context.go(AppRoutes.home);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _roundIcon({required String asset, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(120),
      child: Container(
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.grey200),
        ),
        child: SvgPicture.asset(asset),
      ),
    );
  }
}
