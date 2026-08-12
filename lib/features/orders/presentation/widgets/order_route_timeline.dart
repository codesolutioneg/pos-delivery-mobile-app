import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Restaurant → customer route strip (Yasser timeline, simplified).
class OrderRouteTimeline extends StatelessWidget {
  const OrderRouteTimeline({
    super.key,
    required this.restaurantTitle,
    required this.restaurantAddress,
    required this.customerTitle,
    required this.customerAddress,
    this.onRestaurantCall,
    this.onCustomerCall,
    this.showBoth = true,
    this.restaurantOnly = false,
  });

  final String restaurantTitle;
  final String restaurantAddress;
  final String customerTitle;
  final String customerAddress;
  final VoidCallback? onRestaurantCall;
  final VoidCallback? onCustomerCall;
  final bool showBoth;
  final bool restaurantOnly;

  @override
  Widget build(BuildContext context) {
    if (restaurantOnly) {
      return _row(
        icon: 'assets/icons/ic_building.svg',
        bg: AppColors.primary50,
        tint: AppColors.primary300,
        title: restaurantTitle,
        subtitle: restaurantAddress,
        onCall: onRestaurantCall,
      );
    }
    if (!showBoth) {
      return _row(
        icon: 'assets/icons/ic_location.svg',
        bg: AppColors.driverApp50,
        tint: AppColors.driverApp300,
        title: customerTitle,
        subtitle: customerAddress,
        onCall: onCustomerCall,
      );
    }
    return Column(
      children: [
        _row(
          icon: 'assets/icons/ic_building.svg',
          bg: AppColors.primary50,
          tint: AppColors.primary300,
          title: restaurantTitle,
          subtitle: restaurantAddress,
          onCall: onRestaurantCall,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 2,
              height: 28,
              color: AppColors.grey300,
            ),
          ),
        ),
        _row(
          icon: 'assets/icons/ic_location.svg',
          bg: AppColors.driverApp50,
          tint: AppColors.driverApp300,
          title: customerTitle,
          subtitle: customerAddress,
          onCall: onCustomerCall,
        ),
      ],
    );
  }

  Widget _row({
    required String icon,
    required Color bg,
    required Color tint,
    required String title,
    required String subtitle,
    VoidCallback? onCall,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMd()),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySm()),
            ],
          ),
        ),
        if (onCall != null)
          IconButton(
            onPressed: onCall,
            icon: SvgPicture.asset(
              'assets/icons/ic_phone_call.svg',
              width: 22,
              height: 22,
            ),
          ),
      ],
    );
  }
}
