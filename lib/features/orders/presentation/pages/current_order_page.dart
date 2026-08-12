import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../cubit/current_order_cubit.dart';
import '../cubit/current_order_state.dart';
import '../widgets/active_order_sheet.dart';
import '../widgets/delivery_map_view.dart';

/// Home — map + multi-order sheet (Yasser-style switcher).
class CurrentOrderPage extends StatelessWidget {
  const CurrentOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(title: Text(l10n.navHome)),
          body: authState is! AuthAuthenticated
              ? const Center(child: CircularProgressIndicator())
              : BlocBuilder<CurrentOrderCubit, CurrentOrderState>(
                  builder: (context, state) {
                    return switch (state) {
                      CurrentOrderInitial() || CurrentOrderLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      CurrentOrderFailure(:final message) => Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppDimensions.spaceLg),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style:
                                  AppTextStyles.bodyMd(color: AppColors.error),
                            ),
                          ),
                        ),
                      CurrentOrderEmpty() => const _HomeShell(
                          orders: [],
                          selected: null,
                        ),
                      CurrentOrderLoaded(:final orders, :final selectedId) =>
                        _HomeShell(
                          orders: orders,
                          selected: orders.firstWhere(
                            (o) => o.id == selectedId,
                            orElse: () => orders.first,
                          ),
                        ),
                    };
                  },
                ),
        );
      },
    );
  }
}

class _HomeShell extends StatelessWidget {
  const _HomeShell({
    required this.orders,
    required this.selected,
  });

  final List<DeliveryOrderEntity> orders;
  final DeliveryOrderEntity? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final multi = orders.length > 1;

    return Stack(
      children: [
        DeliveryMapView(
          focusOrderId: selected?.id,
          customerLat: selected?.customerLat,
          customerLng: selected?.customerLng,
          customerAddress: selected?.address,
          areaHint: selected?.restaurantName ?? selected?.restaurantAddress,
        ),
        DraggableScrollableSheet(
          initialChildSize: selected == null
              ? 0.32
              : (multi ? 0.52 : (selected!.isPending ? 0.55 : 0.48)),
          minChildSize: 0.22,
          maxChildSize: 0.92,
          snap: true,
          snapSizes: const [0.22, 0.42, 0.65, 0.92],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selected == null) ...[
                    Icon(
                      Icons.delivery_dining,
                      size: 52,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.waitingDispatch,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMd(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.waitingDispatchHint,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd(),
                    ),
                  ] else ...[
                    if (orders.isNotEmpty) ...[
                      Text(
                        l10n.activeOrders(orders.length),
                        style: AppTextStyles.label(),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final o = orders[index];
                            final selectedChip = o.id == selected!.id;
                            return ChoiceChip(
                              label: Text(o.displayId),
                              selected: selectedChip,
                              selectedColor: AppColors.primary50,
                              labelStyle: AppTextStyles.bodySm(
                                color: selectedChip
                                    ? AppColors.brandPrimary
                                    : AppColors.grey700,
                              ),
                              onSelected: (_) => context
                                  .read<CurrentOrderCubit>()
                                  .selectOrder(o.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    ActiveOrderSheet(order: selected!),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
