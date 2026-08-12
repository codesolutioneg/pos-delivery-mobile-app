import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/driver_rounded_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().login(
          username: _usernameController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final loading = state is AuthLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  const Center(child: BrandLogoBadge(diameter: 128)),
                  const SizedBox(height: 24),
                  Text(
                    AppConfig.brandName,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLg(color: AppColors.brandPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMd(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySm(),
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.usernameLabel, style: AppTextStyles.label()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    enabled: !loading,
                    decoration: InputDecoration(hintText: l10n.usernameHint),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.passwordLabel, style: AppTextStyles.label()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    onSubmitted: (_) => _submit(),
                    enabled: !loading,
                    decoration: InputDecoration(
                      hintText: l10n.passwordHint,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    DriverRoundedButton(
                      title: l10n.loginButton,
                      onPressed: _submit,
                      color: AppColors.brandPrimary,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
