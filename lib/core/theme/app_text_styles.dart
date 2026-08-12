import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Urbanist typography matching Driver-Yasser.
abstract final class AppTextStyles {
  AppTextStyles._();

  static const String regular = 'Urbanist-Regular';
  static const String medium = 'Urbanist-Medium';
  static const String semiBold = 'Urbanist-SemiBold';
  static const String bold = 'Urbanist-Bold';

  static TextStyle titleLg({Color? color}) => TextStyle(
        fontFamily: bold,
        fontSize: 24,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle titleMd({Color? color}) => TextStyle(
        fontFamily: semiBold,
        fontSize: 18,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyMd({Color? color}) => TextStyle(
        fontFamily: medium,
        fontSize: 14,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodySm({Color? color}) => TextStyle(
        fontFamily: regular,
        fontSize: 12,
        color: color ?? AppColors.textMuted,
      );

  static TextStyle button({Color? color}) => TextStyle(
        fontFamily: semiBold,
        fontSize: 14,
        color: color ?? AppColors.textOnDark,
      );

  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: medium,
        fontSize: 13,
        color: color ?? AppColors.grey700,
      );
}
