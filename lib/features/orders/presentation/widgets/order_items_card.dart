import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/my_separator.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../../domain/entities/delivery_order_line_entity.dart';

/// Items list in a card, with bold total at the bottom.
class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({super.key, required this.order});

  final DeliveryOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = order.items.isNotEmpty
        ? order.items
        : _fallbackLines(order.itemsSummary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.orderItems, style: AppTextStyles.label()),
          const SizedBox(height: 10),
          if (lines.isEmpty)
            Text('—', style: AppTextStyles.bodyMd())
          else
            ...lines.map(_itemRow),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: MySeparator(),
          ),
          Row(
            children: [
              Text(
                l10n.total,
                style: AppTextStyles.titleMd(color: AppColors.grey900),
              ),
              const Spacer(),
              Text(
                order.total.toStringAsFixed(2),
                style: AppTextStyles.titleMd(color: AppColors.grey900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _itemRow(DeliveryOrderLineEntity line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              line.name,
              style: AppTextStyles.bodyMd(color: AppColors.grey800),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'x${line.quantity}',
            style: AppTextStyles.label(color: AppColors.driverApp300),
          ),
          if (line.lineTotal != null && line.lineTotal! > 0) ...[
            const SizedBox(width: 12),
            Text(
              line.lineTotal!.toStringAsFixed(2),
              style: AppTextStyles.bodyMd(color: AppColors.grey800),
            ),
          ],
        ],
      ),
    );
  }

  List<DeliveryOrderLineEntity> _fallbackLines(String summary) {
    if (summary.isEmpty || summary == '—') return const [];
    return summary
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) {
          final match = RegExp(r'^(.*)\s+x(\d+)\s*$').firstMatch(s);
          if (match != null) {
            return DeliveryOrderLineEntity(
              name: match.group(1)!.trim(),
              quantity: int.tryParse(match.group(2)!) ?? 1,
            );
          }
          return DeliveryOrderLineEntity(name: s, quantity: 1);
        })
        .toList();
  }
}
