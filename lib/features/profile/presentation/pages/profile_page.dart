import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/driver_rounded_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _call(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = state.driver;
          final phone = (d.phone ?? '').trim();
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary50,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                d.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMd(),
              ),
              const SizedBox(height: 4),
              Text(
                AppConfig.brandName,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm(color: AppColors.brandPrimary),
              ),
              const SizedBox(height: 24),
              _card(
                children: [
                  _row(l10n.driverId, d.id),
                  _row(
                    l10n.username,
                    d.username.isEmpty ? '—' : d.username,
                  ),
                  InkWell(
                    onTap: phone.isEmpty ? null : () => _call(context, phone),
                    child: _row(
                      l10n.phone,
                      phone.isEmpty ? l10n.phoneNotSet : phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.phoneHintProfile,
                style: AppTextStyles.bodySm(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(l10n.language, style: AppTextStyles.titleMd()),
              const SizedBox(height: 10),
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return _card(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'ar',
                              label: Text(l10n.languageArabic),
                            ),
                            ButtonSegment(
                              value: 'en',
                              label: Text(l10n.languageEnglish),
                            ),
                          ],
                          selected: {locale.languageCode},
                          onSelectionChanged: (set) {
                            final code = set.first;
                            context
                                .read<LocaleCubit>()
                                .setLocale(Locale(code));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              DriverRoundedButton(
                title: l10n.logout,
                color: AppColors.error,
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySm())),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMd(color: AppColors.grey800),
            ),
          ),
        ],
      ),
    );
  }
}
