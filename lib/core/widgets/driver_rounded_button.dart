import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Pill CTA matching Driver-Yasser [RoundedButtonFill].
class DriverRoundedButton extends StatelessWidget {
  const DriverRoundedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color,
    this.textColor,
    this.enabled = true,
    this.height = 52,
  });

  final String title;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final bool enabled;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.brandPrimary;
    return Material(
      color: enabled ? bg : AppColors.grey300,
      borderRadius: BorderRadius.circular(200),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(200),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.button(
                color: textColor ?? AppColors.textOnDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
