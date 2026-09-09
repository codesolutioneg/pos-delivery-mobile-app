import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// The active branch logo (`brand_assets/active/icon.png`).
///
/// Falls back to a delivery glyph when the brand has no icon applied yet, so
/// a fresh checkout never shows a broken image.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 96,
    this.fit = BoxFit.contain,
  });

  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.brandLogo,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.delivery_dining_rounded,
        size: size * 0.7,
        color: AppColors.brandPrimary,
      ),
    );
  }
}

/// Brand logo inside a white circle with a soft shadow — the login/splash mark.
class BrandLogoBadge extends StatelessWidget {
  const BrandLogoBadge({
    super.key,
    this.diameter = 132,
    this.logoScale = 0.58,
  });

  final double diameter;
  final double logoScale;

  @override
  Widget build(BuildContext context) {
    final logoSize = diameter * logoScale;
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BrandLogo(size: logoSize),
    );
  }
}
