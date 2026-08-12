import 'package:flutter/material.dart';

/// Horizontal dashed divider (ported from Driver-Yasser).
class MySeparator extends StatelessWidget {
  const MySeparator({
    super.key,
    this.height = 1,
    this.color = const Color(0xFFE5E7EB),
  });

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        final dashCount = (constraints.constrainWidth() / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
