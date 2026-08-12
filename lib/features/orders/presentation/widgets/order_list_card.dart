import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/delivery_order_entity.dart';

class OrderListCard extends StatelessWidget {
  const OrderListCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final DeliveryOrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.customerName, style: AppTextStyles.titleMd()),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status,
                      style: AppTextStyles.bodySm(color: AppColors.brandPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(order.address, style: AppTextStyles.bodySm()),
              const SizedBox(height: 6),
              Text(order.itemsSummary, style: AppTextStyles.bodyMd()),
              const SizedBox(height: 8),
              Text(
                order.total.toStringAsFixed(2),
                style: AppTextStyles.label(color: AppColors.grey800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
