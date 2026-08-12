import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dishflow_delivery/core/l10n/l10n_x.dart';
import 'package:dishflow_delivery/core/theme/app_colors.dart';
import 'package:dishflow_delivery/core/theme/app_text_styles.dart';
import 'package:dishflow_delivery/core/utils/map_marker_factory.dart';
import 'package:dishflow_delivery/features/orders/domain/utils/order_location_resolver.dart';
import 'package:dishflow_delivery/features/orders/domain/utils/order_route_resolver.dart';
import 'package:dishflow_delivery/features/orders/presentation/widgets/route_directions_sheet.dart';

/// Map that follows the selected order: driver + customer pins, the driving
/// route between them, and the live ETA.
class DeliveryMapView extends StatefulWidget {
  const DeliveryMapView({
    super.key,
    this.focusOrderId,
    this.customerLat,
    this.customerLng,
    this.customerAddress,
    this.areaHint,
  });

  final String? focusOrderId;
  final double? customerLat;
  final double? customerLng;
  final String? customerAddress;
  final String? areaHint;

  @override
  State<DeliveryMapView> createState() => _DeliveryMapViewState();
}

class _DeliveryMapViewState extends State<DeliveryMapView> {
  static const LatLng _fallback = LatLng(30.0444, 31.2357);

  /// Re-route only after the driver has really moved, to spare Directions quota.
  static const double _rerouteDistanceMeters = 150;
  static const Duration _rerouteInterval = Duration(seconds: 45);

  GoogleMapController? _controller;
  StreamSubscription<Position>? _positionSub;

  LatLng _driver = _fallback;
  LatLng? _customer;
  bool _customerApproximate = false;
  bool _locatingCustomer = false;
  String? _resolveError;
  int _resolveToken = 0;

  DeliveryRoute? _route;
  bool _routeLoading = false;
  int _routeToken = 0;
  LatLng? _routedFrom;
  DateTime? _routedAt;

  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _customerIcon;

  @override
  void initState() {
    super.initState();
    unawaited(_initDriverLocation());
    unawaited(_resolveCustomer());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_loadMarkerIcons());
  }

  @override
  void didUpdateWidget(covariant DeliveryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool changed = oldWidget.focusOrderId != widget.focusOrderId ||
        oldWidget.customerLat != widget.customerLat ||
        oldWidget.customerLng != widget.customerLng ||
        oldWidget.customerAddress != widget.customerAddress ||
        oldWidget.areaHint != widget.areaHint;
    if (changed) {
      unawaited(_resolveCustomer());
    }
  }

  @override
  void dispose() {
    unawaited(_positionSub?.cancel());
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    if (_driverIcon != null && _customerIcon != null) {
      return;
    }
    final double ratio = MediaQuery.devicePixelRatioOf(context);
    final BitmapDescriptor driver = await MapMarkerFactory.pin(
      icon: Icons.delivery_dining_rounded,
      color: AppColors.brandPrimary,
      devicePixelRatio: ratio,
    );
    final BitmapDescriptor customer = await MapMarkerFactory.pin(
      icon: Icons.person_rounded,
      color: _customerPinColor,
      devicePixelRatio: ratio,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _driverIcon = driver;
      _customerIcon = customer;
    });
  }

  static const Color _customerPinColor = Color(0xFFF2711C);

  Future<void> _initDriverLocation() async {
    final bool serviceOn = await Geolocator.isLocationServiceEnabled();
    if (!serviceOn) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final Position pos = await Geolocator.getCurrentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _driver = LatLng(pos.latitude, pos.longitude);
      });
      await _fitCamera();
      unawaited(_resolveRoute());
      _listenToDriverMovement();
    } on Exception {
      // Keep Cairo fallback.
    }
  }

  /// Keeps the driver pin and the ETA fresh while driving.
  void _listenToDriverMovement() {
    _positionSub ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
      ),
    ).listen(
      (Position pos) {
        if (!mounted) {
          return;
        }
        setState(() {
          _driver = LatLng(pos.latitude, pos.longitude);
        });
        if (_shouldReroute()) {
          unawaited(_resolveRoute());
        }
      },
      onError: (_) {
        // Losing the stream keeps the last known position.
      },
    );
  }

  bool _shouldReroute() {
    if (_customer == null || _routeLoading) {
      return false;
    }
    final LatLng? from = _routedFrom;
    final DateTime? at = _routedAt;
    if (from == null || at == null) {
      return true;
    }
    if (OrderRouteResolver.distanceBetween(from, _driver) >=
        _rerouteDistanceMeters) {
      return true;
    }
    return DateTime.now().difference(at) >= _rerouteInterval;
  }

  Future<void> _resolveCustomer() async {
    final int token = ++_resolveToken;
    final String? orderId = widget.focusOrderId;

    if (orderId == null || orderId.isEmpty) {
      if (!mounted || token != _resolveToken) {
        return;
      }
      setState(() {
        _customer = null;
        _customerApproximate = false;
        _locatingCustomer = false;
        _resolveError = null;
        _clearRoute();
      });
      return;
    }

    setState(() {
      _locatingCustomer = true;
      _resolveError = null;
    });

    final ResolvedOrderLocation? resolved =
        await OrderLocationResolver.resolve(
      lat: widget.customerLat,
      lng: widget.customerLng,
      address: widget.customerAddress,
      areaHint: widget.areaHint,
    );

    if (!mounted || token != _resolveToken) {
      return;
    }

    if (resolved == null) {
      setState(() {
        _customer = null;
        _customerApproximate = false;
        _locatingCustomer = false;
        _resolveError = context.l10n.mapCustomerNotFound;
        _clearRoute();
      });
      return;
    }

    setState(() {
      _customer = resolved.point;
      _customerApproximate = resolved.isApproximate;
      _locatingCustomer = false;
      _resolveError = null;
      _clearRoute();
    });
    await _fitCamera();
    await _resolveRoute();
  }

  void _clearRoute() {
    _routeToken++;
    _route = null;
    _routeLoading = false;
    _routedFrom = null;
    _routedAt = null;
  }

  Future<void> _resolveRoute() async {
    final LatLng? customer = _customer;
    if (customer == null) {
      return;
    }

    final int token = ++_routeToken;
    final LatLng from = _driver;
    setState(() => _routeLoading = true);

    final DeliveryRoute route = await OrderRouteResolver.resolve(
      from: from,
      to: customer,
      language: Localizations.localeOf(context).languageCode,
    );

    if (!mounted || token != _routeToken) {
      return;
    }
    setState(() {
      _route = route;
      _routeLoading = false;
      _routedFrom = from;
      _routedAt = DateTime.now();
    });
  }

  void _showDirections() {
    final DeliveryRoute? route = _route;
    if (route == null) {
      return;
    }
    RouteDirectionsSheet.show(
      context,
      route: route,
      onNavigate: () {
        Navigator.of(context).pop();
        unawaited(_openExternalNavigation());
      },
    );
  }

  /// Hands the customer's coordinates to Google Maps for real turn-by-turn.
  ///
  /// In-app navigation is deliberately out of scope: the map shows the route and
  /// the steps, the phone's navigator does the voice guidance.
  Future<void> _openExternalNavigation() async {
    final LatLng? customer = _customer;
    if (customer == null) {
      return;
    }

    final String target = '${customer.latitude},${customer.longitude}';
    // Android's navigation intent first, then the cross-platform web fallback.
    final List<Uri> candidates = <Uri>[
      Uri.parse('google.navigation:q=$target&mode=d'),
      Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$target'
        '&travelmode=driving&dir_action=navigate',
      ),
    ];

    for (final Uri uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return;
        }
      } on PlatformException {
        // Try the next candidate.
      }
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.mapNavigateFailed),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _fitCamera() async {
    final GoogleMapController? controller = _controller;
    final LatLng? customer = _customer;
    if (controller == null) {
      return;
    }

    if (customer == null) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(_driver, 14));
      return;
    }

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _driver.latitude < customer.latitude
            ? _driver.latitude
            : customer.latitude,
        _driver.longitude < customer.longitude
            ? _driver.longitude
            : customer.longitude,
      ),
      northeast: LatLng(
        _driver.latitude > customer.latitude
            ? _driver.latitude
            : customer.latitude,
        _driver.longitude > customer.longitude
            ? _driver.longitude
            : customer.longitude,
      ),
    );

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 72),
      );
    } on Exception {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(customer, 15),
      );
    }
  }

  Set<Marker> get _markers {
    final Set<Marker> markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: _driver,
        anchor: const Offset(0.5, 1),
        infoWindow: InfoWindow(title: context.l10n.mapYouMarker),
        icon: _driverIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    final LatLng? customer = _customer;
    if (customer != null) {
      markers.add(
        Marker(
          markerId: MarkerId('customer_${widget.focusOrderId ?? 'x'}'),
          position: customer,
          anchor: const Offset(0.5, 1),
          infoWindow: InfoWindow(
            title: context.l10n.mapCustomerMarker,
            snippet: _customerApproximate
                ? context.l10n.mapApproximateHint
                : null,
          ),
          icon: _customerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> get _polylines {
    final DeliveryRoute? route = _route;
    if (route == null || route.points.length < 2) {
      return const <Polyline>{};
    }
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('driver_to_customer'),
        points: route.points,
        color: AppColors.brandPrimary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        // A dashed line signals "this is not the real road path".
        patterns: route.isEstimate
            ? <PatternItem>[PatternItem.dash(24), PatternItem.gap(14)]
            : const <PatternItem>[],
        geodesic: route.isEstimate,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _driver, zoom: 13),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            unawaited(_fitCamera());
          },
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_locatingCustomer)
                _MapBanner(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.mapLocatingCustomer,
                          style: AppTextStyles.bodySm(),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_resolveError != null)
                _MapBanner(
                  child: Text(
                    _resolveError!,
                    style: AppTextStyles.bodySm(color: AppColors.error),
                  ),
                )
              else if (_customerApproximate && _customer != null)
                _MapBanner(
                  child: Text(
                    l10n.mapApproximateHint,
                    style: AppTextStyles.bodySm(),
                  ),
                ),
              if (_customer != null && (_route != null || _routeLoading))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _EtaCard(
                    route: _route,
                    loading: _routeLoading,
                    onShowSteps: _showDirections,
                    onNavigate: _openExternalNavigation,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "12 min · 4.3 km" summary for the driver → customer leg.
class _EtaCard extends StatelessWidget {
  const _EtaCard({
    required this.route,
    required this.loading,
    required this.onShowSteps,
    required this.onNavigate,
  });

  final DeliveryRoute? route;
  final bool loading;
  final VoidCallback onShowSteps;
  final Future<void> Function() onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final DeliveryRoute? route = this.route;

    if (route == null) {
      return _MapBanner(
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.mapRouteCalculating,
                style: AppTextStyles.bodySm(),
              ),
            ),
          ],
        ),
      );
    }

    return _MapBanner(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 20,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _durationLabel(context, route.duration),
                      style: AppTextStyles.titleMd(
                        color: AppColors.brandPrimary,
                      ),
                    ),
                    Text(
                      '  ·  ${_distanceLabel(context, route.distanceMeters)}',
                      style: AppTextStyles.bodySm(),
                    ),
                  ],
                ),
                Text(
                  l10n.mapRouteToCustomer,
                  style: AppTextStyles.bodySm(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (route.isEstimate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.mapRouteEstimateTag,
                style: AppTextStyles.bodySm(color: AppColors.textMuted),
              ),
            ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          // Steps list — only meaningful for a real road route.
          if (route.hasSteps)
            IconButton(
              onPressed: onShowSteps,
              tooltip: l10n.mapDirectionsTitle,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.list_alt_rounded,
                color: AppColors.brandPrimary,
              ),
            ),
          // Voice guidance always available — it is the phone's navigator.
          IconButton(
            onPressed: () => onNavigate(),
            tooltip: l10n.mapNavigate,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.navigation_rounded,
              color: AppColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(BuildContext context, Duration duration) {
    final l10n = context.l10n;
    final int totalMinutes = duration.inSeconds <= 0
        ? 0
        : (duration.inSeconds / 60).ceil();
    if (totalMinutes < 60) {
      return l10n.mapRouteMinutes(totalMinutes);
    }
    return l10n.mapRouteHoursMinutes(totalMinutes ~/ 60, totalMinutes % 60);
  }

  String _distanceLabel(BuildContext context, int meters) {
    final l10n = context.l10n;
    if (meters < 1000) {
      return l10n.mapRouteDistanceMeters(meters);
    }
    return l10n.mapRouteDistanceKm((meters / 1000).toStringAsFixed(1));
  }
}

class _MapBanner extends StatelessWidget {
  const _MapBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child,
      ),
    );
  }
}
