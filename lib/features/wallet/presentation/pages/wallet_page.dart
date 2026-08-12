import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: Text(l10n.navWallet)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandPrimary,
                  AppColors.brandPrimary.withValues(alpha: 0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic_wallet.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'EGP',
                      style: AppTextStyles.bodySm(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '0.00',
                  style: AppTextStyles.titleLg(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.walletBalance,
                  style: AppTextStyles.bodySm(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.recentActivity, style: AppTextStyles.titleMd()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 40, color: AppColors.grey400),
                const SizedBox(height: 12),
                Text(
                  l10n.noWalletTx,
                  style: AppTextStyles.bodyMd(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.noWalletTxHint,
                  style: AppTextStyles.bodySm(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
