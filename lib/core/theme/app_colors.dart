import 'package:flutter/material.dart';

import '../config/app_config.dart';

/// Driver-Yasser visual tokens (ported).
abstract final class AppColors {
  AppColors._();

  /// White-label override when PRIMARY_COLOR is set; else Yasser brand blue.
  static Color get brandPrimary {
    const fromDefine = AppConfig.primaryColorValue;
    if (fromDefine != 0xFFFF6B35) return Color(fromDefine);
    return primary300;
  }

  static const Color primary300 = Color(0xFF009DE0);
  static const Color primary50 = Color.fromARGB(20, 0, 157, 224);

  static const Color driverApp300 = Color(0xFF5BC236);
  static const Color driverApp50 = Color(0xFFEFF9EB);

  static const Color success = Color(0xFF10B271);
  static const Color error = Color(0xFFFF3840);
  static const Color warning = Color(0xFFFFCB39);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color bgPrimary = Color(0xFFF3F4F6);
  static const Color bgSecondary = Color(0xFFFFFFFF);

  static const Color grey50 = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey600;
  static const Color textMuted = grey500;

  static const Color inputFill = grey100;
}
