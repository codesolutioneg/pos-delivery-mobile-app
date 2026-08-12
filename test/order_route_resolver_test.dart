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

  group('parseSteps', () {
    test('flattens legs → steps with instruction, distance, duration', () {
      final steps = OrderRouteResolver.parseSteps(<dynamic>[
        <String, dynamic>{
          'steps': <dynamic>[
            <String, dynamic>{
              'navigationInstruction': <String, dynamic>{
                'instructions': 'Head north on Tahrir St.',
                'maneuver': 'DEPART',
              },
              'distanceMeters': 420,
              'staticDuration': '95s',
              'startLocation': <String, dynamic>{
                'latLng': <String, dynamic>{
                  'latitude': 30.0444,
                  'longitude': 31.2357,
                },
              },
            },
            <String, dynamic>{
              'navigationInstruction': <String, dynamic>{
                'instructions': 'Turn right onto Ramses St.',
                'maneuver': 'TURN_RIGHT',
              },
              'distanceMeters': 1300,
              'staticDuration': '240s',
            },
          ],
        },
      ]);

      expect(steps, hasLength(2));
      expect(steps[0].instruction, 'Head north on Tahrir St.');
      expect(steps[0].maneuver, 'DEPART');
      expect(steps[0].distanceMeters, 420);
      expect(steps[0].duration, const Duration(seconds: 95));
      expect(steps[0].start.latitude, closeTo(30.0444, 0.00001));
      expect(steps[1].maneuver, 'TURN_RIGHT');
      // Missing startLocation must not throw; it degrades to (0, 0).
      expect(steps[1].start.latitude, 0);
    });

    test('drops steps with no instruction text', () {
      final steps = OrderRouteResolver.parseSteps(<dynamic>[
        <String, dynamic>{
          'steps': <dynamic>[
            <String, dynamic>{
              'navigationInstruction': <String, dynamic>{'instructions': '  '},
            },
            <String, dynamic>{'distanceMeters': 10},
            <String, dynamic>{
              'navigationInstruction': <String, dynamic>{
                'instructions': 'Continue straight',
              },
            },
          ],
        },
      ]);

      expect(steps, hasLength(1));
      expect(steps.single.instruction, 'Continue straight');
    });

    test('returns empty for null / empty / malformed legs', () {
      expect(OrderRouteResolver.parseSteps(null), isEmpty);
      expect(OrderRouteResolver.parseSteps(<dynamic>[]), isEmpty);
      expect(OrderRouteResolver.parseSteps(<dynamic>['nonsense']), isEmpty);
      expect(
        OrderRouteResolver.parseSteps(<dynamic>[<String, dynamic>{}]),
        isEmpty,
      );
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
