import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_logo.dart';

/// Animated launch screen: the branch logo lands, then a scooter rides off.
///
/// Routing away from here is owned by the router + [SplashGate]; this page only
/// animates.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// Pulsing rings behind the logo + the scooter ride, both looping.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.62, curve: Curves.elasticOut),
  );

  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.38, 0.78, curve: Curves.easeOut),
  );

  late final Animation<double> _roadFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.55, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _loop.repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _PulseRings(animation: _loop),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const BrandLogoBadge(diameter: 132),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text(
                      AppConfig.brandName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLg(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.splashTagline,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _roadFade,
                child: _ScooterRide(animation: _loop),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two rings expanding outward from the logo, staggered half a cycle apart.
class _PulseRings extends StatelessWidget {
  const _PulseRings({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _ring((animation.value + 0.5) % 1.0),
            _ring(animation.value),
          ],
        );
      },
    );
  }

  Widget _ring(double t) {
    final eased = Curves.easeOut.transform(t);
    return Opacity(
      opacity: (1 - eased) * 0.35,
      child: Container(
        width: 132 + eased * 68,
        height: 132 + eased * 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandPrimary, width: 2),
        ),
      ),
    );
  }
}

/// Delivery scooter riding along a dashed road, with the road sliding under it.
class _ScooterRide extends StatelessWidget {
  const _ScooterRide({required this.animation});

  final Animation<double> animation;

  static const double _trackHeight = 64;
  static const double _scooterSize = 44;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, 260.0);
        return SizedBox(
          width: width,
          height: _trackHeight,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final t = animation.value;
              // Ease in/out so the scooter looks like it accelerates away.
              final progress = Curves.easeInOut.transform(t);
              final travel = width + _scooterSize;
              final dx = -_scooterSize + travel * progress;
              // Small bob, two bounces per lap.
              final bob = math.sin(t * math.pi * 4) * 2.5;
              // Fade in on entry, out on exit, so the loop has no hard cut.
              final edgeFade = math.min(1.0, math.min(t, 1 - t) / 0.12);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: _DashedRoad(offset: t),
                  ),
                  Positioned(
                    left: dx,
                    bottom: 18 + bob,
                    child: Opacity(
                      opacity: edgeFade.clamp(0.0, 1.0),
                      child: Icon(
                        Icons.delivery_dining_rounded,
                        size: _scooterSize,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _DashedRoad extends StatelessWidget {
  const _DashedRoad({required this.offset});

  /// 0..1 phase; the dashes slide left by one dash period per cycle.
  final double offset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: CustomPaint(
        painter: _DashedRoadPainter(
          offset: offset,
          color: AppColors.grey300,
        ),
      ),
    );
  }
}

class _DashedRoadPainter extends CustomPainter {
  const _DashedRoadPainter({required this.offset, required this.color});

  final double offset;
  final Color color;

  static const double _dash = 14;
  static const double _gap = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final period = _dash + _gap;
    // Slide left by exactly one period per cycle, starting off-screen so the
    // pattern is seamless at the loop boundary.
    var x = -period - offset * period;
    while (x < size.width) {
      final start = math.max(x, 0.0);
      final end = math.min(x + _dash, size.width);
      if (end > start) {
        canvas.drawLine(
          Offset(start, size.height / 2),
          Offset(end, size.height / 2),
          paint,
        );
      }
      x += period;
    }
  }

  @override
  bool shouldRepaint(_DashedRoadPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.color != color;
}
