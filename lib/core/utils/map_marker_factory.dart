import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Builds map markers by painting a Material icon into a teardrop pin, so the
/// driver/customer pins need no bundled PNG assets.
abstract final class MapMarkerFactory {
  MapMarkerFactory._();

  static final Map<String, BitmapDescriptor> _cache =
      <String, BitmapDescriptor>{};

  /// Pin with [icon] knocked out in white on a [color] body.
  ///
  /// [diameter] is the logical width of the pin head; the tail adds ~28% more
  /// height. Results are cached per icon/color/size/ratio.
  static Future<BitmapDescriptor> pin({
    required IconData icon,
    required Color color,
    double diameter = 46,
    double devicePixelRatio = 3,
  }) async {
    final String key = '${icon.codePoint}_${color.toARGB32()}_'
        '${diameter.toStringAsFixed(1)}_${devicePixelRatio.toStringAsFixed(2)}';
    final BitmapDescriptor? cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final double width = diameter;
    final double height = diameter * 1.28;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(devicePixelRatio);

    final double cx = width / 2;
    final double cy = width / 2;
    final double radius = width / 2 - 2;

    final Path head = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    final Path tail = Path()
      ..moveTo(cx - radius * 0.52, cy + radius * 0.78)
      ..lineTo(cx, height - 1)
      ..lineTo(cx + radius * 0.52, cy + radius * 0.78)
      ..close();
    final Path pinPath = Path.combine(PathOperation.union, head, tail);

    canvas.drawShadow(pinPath, Colors.black.withValues(alpha: 0.45), 3, false);
    canvas.drawPath(pinPath, Paint()..color = color);
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final TextPainter glyph = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: radius * 1.25,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
          height: 1,
        ),
      )
      ..layout();
    glyph.paint(
      canvas,
      Offset(cx - glyph.width / 2, cy - glyph.height / 2),
    );

    final ui.Image image = await recorder.endRecording().toImage(
          (width * devicePixelRatio).ceil(),
          (height * devicePixelRatio).ceil(),
        );
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (data == null) {
      // Fall back to a stock pin rather than showing nothing.
      return BitmapDescriptor.defaultMarker;
    }

    final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
      data.buffer.asUint8List(),
      imagePixelRatio: devicePixelRatio,
    );
    _cache[key] = descriptor;
    return descriptor;
  }
}
