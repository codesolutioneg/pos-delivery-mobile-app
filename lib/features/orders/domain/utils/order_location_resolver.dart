import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

/// Resolves a customer pin for the map: exact coords, or approximate geocode.
class OrderLocationResolver {
  OrderLocationResolver._();

  static final Map<String, LatLng> _cache = <String, LatLng>{};

  /// Created lazily so the platform plugin is registered before first use.
  static Geocoding? _geocoding;
  static Geocoding get _geocoder => _geocoding ??= Geocoding();

  /// Prefer [lat]/[lng] when present; otherwise geocode [address].
  static Future<ResolvedOrderLocation?> resolve({
    required double? lat,
    required double? lng,
    required String? address,
    String? areaHint,
  }) async {
    if (lat != null && lng != null) {
      return ResolvedOrderLocation(
        point: LatLng(lat, lng),
        isApproximate: false,
      );
    }

    final query = _buildQuery(address: address, areaHint: areaHint);
    if (query.isEmpty) {
      return null;
    }

    final cached = _cache[query];
    if (cached != null) {
      return ResolvedOrderLocation(point: cached, isApproximate: true);
    }

    try {
      final List<Location> results = await _geocoder.locationFromAddress(query);
      if (results.isEmpty) {
        return null;
      }
      final Location first = results.first;
      final LatLng point = LatLng(first.latitude, first.longitude);
      _cache[query] = point;
      return ResolvedOrderLocation(point: point, isApproximate: true);
    } on Exception {
      return null;
    }
  }

  static String _buildQuery({
    required String? address,
    String? areaHint,
  }) {
    final String trimmed = (address ?? '').trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final List<String> parts = <String>[trimmed];
    final String hint = (areaHint ?? '').trim();
    if (hint.isNotEmpty) {
      parts.add(hint);
    }

    final String lower = trimmed.toLowerCase();
    final bool hasCity = lower.contains('cairo') ||
        trimmed.contains('القاهرة') ||
        lower.contains('giza') ||
        trimmed.contains('الجيزة');
    if (!hasCity) {
      parts.add('Cairo');
    }
    parts.add('Egypt');
    return parts.join(', ');
  }
}

class ResolvedOrderLocation {
  const ResolvedOrderLocation({
    required this.point,
    required this.isApproximate,
  });

  final LatLng point;
  final bool isApproximate;
}
