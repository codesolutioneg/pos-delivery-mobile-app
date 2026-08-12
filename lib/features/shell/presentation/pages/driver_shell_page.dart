import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../orders/presentation/pages/current_order_page.dart';
import '../../../orders/presentation/pages/orders_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';

/// Bottom nav: Home / Orders / Wallet / Profile.
class DriverShellPage extends StatefulWidget {
  const DriverShellPage({super.key});

  @override
  State<DriverShellPage> createState() => _DriverShellPageState();
}

class _DriverShellPageState extends State<DriverShellPage> {
  int _index = 0;

  final List<Widget> _pages = const [
    CurrentOrderPage(),
    OrdersListPage(),
    WalletPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.grey500,
        selectedLabelStyle: AppTextStyles.bodySm(color: AppColors.brandPrimary),
        unselectedLabelStyle: AppTextStyles.bodySm(),
        backgroundColor: AppColors.surface,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/ic_home.svg', 0),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/ic_orders.svg', 1),
            label: l10n.navOrders,
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/ic_wallet.svg', 2),
            label: l10n.navWallet,
          ),
          BottomNavigationBarItem(
            icon: _navIcon('assets/icons/ic_profile.svg', 3),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _navIcon(String asset, int i) {
    final selected = _index == i;
    return SvgPicture.asset(
      asset,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        selected ? AppColors.brandPrimary : AppColors.grey500,
        BlendMode.srcIn,
      ),
    );
  }
}
