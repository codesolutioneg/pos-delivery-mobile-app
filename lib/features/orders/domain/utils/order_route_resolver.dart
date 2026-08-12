import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/app_config.dart';

/// Driving route between the driver and the customer, with its ETA.
class DeliveryRoute {
  const DeliveryRoute({
    required this.points,
    required this.distanceMeters,
    required this.duration,
    required this.isEstimate,
  });

  /// Polyline to draw; at minimum the two endpoints.
  final List<LatLng> points;
  final int distanceMeters;
  final Duration duration;

  /// True when the Directions API was unavailable and this is a straight-line
  /// estimate instead of a real road route.
  final bool isEstimate;
}

/// Resolves the driving route + ETA from the driver to the customer.
///
/// Uses the Google Routes API (`v2:computeRoutes`) when it answers; otherwise
/// falls back to a straight line with a distance-based ETA so the driver still
/// sees something useful offline or when the key has no Routes access.
abstract final class OrderRouteResolver {
  OrderRouteResolver._();

  /// Average city driving speed used by the fallback estimate.
  static const double _fallbackKmh = 25;

  /// Straight line distances underestimate road distance; scale them up.
  static const double _roadFactor = 1.35;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<DeliveryRoute> resolve({
    required LatLng from,
    required LatLng to,
    String language = 'en',
  }) async {
    final DeliveryRoute? routed =
        await _fromRoutesApi(from: from, to: to, language: language);
    return routed ?? _straightLine(from: from, to: to);
  }

  static Future<DeliveryRoute?> _fromRoutesApi({
    required LatLng from,
    required LatLng to,
    required String language,
  }) async {
    if (AppConfig.mapsApiKey.isEmpty) {
      return null;
    }

    try {
      final Response<Map<String, dynamic>> response =
          await _dio.post<Map<String, dynamic>>(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': AppConfig.mapsApiKey,
            'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,'
                'routes.polyline.encodedPolyline',
          },
          // Non-2xx means "no route" here, not a crash.
          validateStatus: (_) => true,
        ),
        data: <String, dynamic>{
          'origin': _waypoint(from),
          'destination': _waypoint(to),
          'travelMode': 'DRIVE',
          'routingPreference': 'TRAFFIC_AWARE',
          'languageCode': language,
          'units': 'METRIC',
        },
      );

      final Map<String, dynamic>? body = response.data;
      if (response.statusCode != 200 || body == null) {
        return null;
      }

      final List<dynamic>? routes = body['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        return null;
      }

      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
      final int meters = (route['distanceMeters'] as num?)?.round() ?? 0;
      final Duration? duration = _parseDuration(route['duration'] as String?);
      final String? encoded = (route['polyline'] as Map<String, dynamic>?)?[
          'encodedPolyline'] as String?;

      if (duration == null || meters <= 0) {
        return null;
      }

      final List<LatLng> points =
          encoded == null ? <LatLng>[from, to] : decodePolyline(encoded);
      if (points.length < 2) {
        return null;
      }

      return DeliveryRoute(
        points: points,
        distanceMeters: meters,
        duration: duration,
        isEstimate: false,
      );
    } on DioException {
      return null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static Map<String, dynamic> _waypoint(LatLng point) => <String, dynamic>{
        'location': <String, dynamic>{
          'latLng': <String, double>{
            'latitude': point.latitude,
            'longitude': point.longitude,
          },
        },
      };

  /// Routes API returns protobuf durations as seconds with a trailing `s`.
  static Duration? _parseDuration(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final double? seconds = double.tryParse(raw.replaceAll('s', ''));
    if (seconds == null) {
      return null;
    }
    return Duration(seconds: seconds.round());
  }

  static DeliveryRoute _straightLine({
    required LatLng from,
    required LatLng to,
  }) {
    final double meters = distanceBetween(from, to) * _roadFactor;
    final double hours = (meters / 1000) / _fallbackKmh;
    return DeliveryRoute(
      points: <LatLng>[from, to],
      distanceMeters: meters.round(),
      duration: Duration(seconds: math.max(60, (hours * 3600).round())),
      isEstimate: true,
    );
  }

  /// Great-circle distance in meters.
  static double distanceBetween(LatLng a, LatLng b) {
    const double earthRadius = 6371000;
    final double dLat = _rad(b.latitude - a.latitude);
    final double dLng = _rad(b.longitude - a.longitude);
    final double h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthRadius * math.asin(math.min(1, math.sqrt(h)));
  }

  static double _rad(double degrees) => degrees * math.pi / 180;

  /// Decodes a Google encoded polyline string into coordinates.
  ///
  /// A truncated trailing group is dropped rather than throwing.
  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      bool truncated = false;

      // Two varint groups per point: latitude delta, then longitude delta.
      final List<int> deltas = <int>[];
      for (int group = 0; group < 2; group++) {
        shift = 0;
        result = 0;
        do {
          if (index >= encoded.length) {
            truncated = true;
            break;
          }
          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);
        if (truncated) {
          break;
        }
        deltas.add((result & 1) != 0 ? ~(result >> 1) : result >> 1);
      }

      if (truncated || deltas.length < 2) {
        break;
      }

      lat += deltas[0];
      lng += deltas[1];
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
