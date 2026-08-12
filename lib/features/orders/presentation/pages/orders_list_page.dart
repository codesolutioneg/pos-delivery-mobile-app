import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/delivery_order_entity.dart';
import '../cubit/orders_list_cubit.dart';
import '../cubit/orders_list_state.dart';
import '../widgets/order_list_card.dart';

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) {
      context.read<OrdersListCubit>().watch(driverUid: auth.driver.id);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(l10n.navOrders),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.brandPrimary,
          labelColor: AppColors.brandPrimary,
          unselectedLabelColor: AppColors.grey500,
          labelStyle: AppTextStyles.label(),
          tabs: [
            Tab(text: l10n.ordersActive),
            Tab(text: l10n.ordersCompleted),
          ],
        ),
      ),
      body: BlocBuilder<OrdersListCubit, OrdersListState>(
        builder: (context, state) {
          return switch (state) {
            OrdersListInitial() || OrdersListLoading() =>
              const Center(child: CircularProgressIndicator()),
            OrdersListFailure(:final message) => Center(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMd(color: AppColors.error),
                ),
              ),
            OrdersListLoaded(:final active, :final completed) => TabBarView(
                controller: _tabs,
                children: [
                  _list(context, active),
                  _list(context, completed),
                ],
              ),
          };
        },
      ),
    );
  }

  Widget _list(BuildContext context, List<DeliveryOrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(context.l10n.noOrders, style: AppTextStyles.bodyMd()),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderListCard(
          order: order,
          onTap: () =>
              context.push(AppRoutes.orderDetail(order.id), extra: order),
        );
      },
    );
  }
}
