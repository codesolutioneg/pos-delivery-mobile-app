import 'package:dishflow_delivery/features/orders/domain/utils/order_route_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('decodePolyline', () {
    test('decodes the example from the Google encoding reference', () {
      final points =
          OrderRouteResolver.decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');

      expect(points, hasLength(3));
      expect(points[0].latitude, closeTo(38.5, 0.00001));
      expect(points[0].longitude, closeTo(-120.2, 0.00001));
      expect(points[1].latitude, closeTo(40.7, 0.00001));
      expect(points[1].longitude, closeTo(-120.95, 0.00001));
      expect(points[2].latitude, closeTo(43.252, 0.00001));
      expect(points[2].longitude, closeTo(-126.453, 0.00001));
    });

    test('returns empty for empty input', () {
      expect(OrderRouteResolver.decodePolyline(''), isEmpty);
    });

    test('drops a truncated trailing group instead of throwing', () {
      // Full string minus its last character: the final point is incomplete.
      const truncated = '_p~iF~ps|U_ulLnnqC_mqNvxq';
      final points = OrderRouteResolver.decodePolyline(truncated);

      expect(points, hasLength(2));
      expect(points.last.latitude, closeTo(40.7, 0.00001));
    });
  });

  group('distanceBetween', () {
    test('matches a known Cairo distance within 1%', () {
      // Tahrir Square → Giza Pyramids: ~7.25 km north-south and ~9.77 km
      // east-west at this latitude, so ~12.17 km great-circle.
      const tahrir = LatLng(30.0444, 31.2357);
      const giza = LatLng(29.9792, 31.1342);

      final meters = OrderRouteResolver.distanceBetween(tahrir, giza);

      expect(meters, closeTo(12170, 122));
    });

    test('is zero for the same point', () {
      const p = LatLng(30.0444, 31.2357);
      expect(OrderRouteResolver.distanceBetween(p, p), closeTo(0, 0.001));
    });
  });
}
