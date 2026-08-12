import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/utils/order_route_resolver.dart';

/// Turn-by-turn maneuvers for the current route, as a bottom sheet.
class RouteDirectionsSheet extends StatelessWidget {
  const RouteDirectionsSheet({
    super.key,
    required this.route,
    this.onNavigate,
  });

  final DeliveryRoute route;
  final VoidCallback? onNavigate;

  static Future<void> show(
    BuildContext context, {
    required DeliveryRoute route,
    VoidCallback? onNavigate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RouteDirectionsSheet(
        route: route,
        onNavigate: onNavigate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.mapDirectionsTitle,
                          style: AppTextStyles.titleMd(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.mapDirectionsSteps(route.steps.length),
                          style: AppTextStyles.bodySm(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onNavigate != null)
                    TextButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: Text(l10n.mapNavigate),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.brandPrimary,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (!route.hasSteps)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.mapDirectionsUnavailable,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm(),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: route.steps.length + 1,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 68,
                  ),
                  itemBuilder: (context, index) {
                    if (index == route.steps.length) {
                      return _StepTile(
                        icon: Icons.location_on_rounded,
                        color: AppColors.success,
                        instruction: l10n.mapDirectionsArrive,
                        trailing: null,
                      );
                    }
                    final RouteStep step = route.steps[index];
                    return _StepTile(
                      icon: _maneuverIcon(step.maneuver),
                      color: AppColors.brandPrimary,
                      instruction: step.instruction,
                      trailing: _stepDistance(context, step.distanceMeters),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _stepDistance(BuildContext context, int meters) {
    final l10n = context.l10n;
    if (meters < 1000) {
      return l10n.mapRouteDistanceMeters(meters);
    }
    return l10n.mapRouteDistanceKm((meters / 1000).toStringAsFixed(1));
  }

  /// Maps a Routes API maneuver enum to an arrow the driver can read at a glance.
  static IconData _maneuverIcon(String maneuver) {
    switch (maneuver) {
      case 'TURN_LEFT':
      case 'TURN_SLIGHT_LEFT':
      case 'FORK_LEFT':
      case 'RAMP_LEFT':
        return Icons.turn_left_rounded;
      case 'TURN_RIGHT':
      case 'TURN_SLIGHT_RIGHT':
      case 'FORK_RIGHT':
      case 'RAMP_RIGHT':
        return Icons.turn_right_rounded;
      case 'TURN_SHARP_LEFT':
        return Icons.turn_sharp_left_rounded;
      case 'TURN_SHARP_RIGHT':
        return Icons.turn_sharp_right_rounded;
      case 'UTURN_LEFT':
      case 'UTURN_RIGHT':
        return Icons.u_turn_left_rounded;
      case 'ROUNDABOUT_LEFT':
      case 'ROUNDABOUT_RIGHT':
        return Icons.roundabout_left_rounded;
      case 'MERGE':
        return Icons.merge_rounded;
      case 'DEPART':
        return Icons.trip_origin_rounded;
      case 'NAME_CHANGE':
      case 'STRAIGHT':
      default:
        return Icons.straight_rounded;
    }
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.icon,
    required this.color,
    required this.instruction,
    required this.trailing,
  });

  final IconData icon;
  final Color color;
  final String instruction;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(instruction, style: AppTextStyles.bodySm()),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            Text(
              trailing!,
              style: AppTextStyles.bodySm(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
