import 'package:flutter_map/flutter_map.dart';

import '../config/app_config.dart';

/// Raster basemap that does not depend on a Google Maps SDK key.
///
/// The iOS Maps SDK key in AppDelegate was expired (`REQUEST_DENIED`), and
/// OSM's public tiles often serve a blocked placeholder to Dart user-agents.
/// Carto tiles plus an identifying User-Agent render without billing.
abstract final class AppMapTiles {
  AppMapTiles._();

  static const String urlTemplate =
      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

  static TileLayer layer() {
    const package = String.fromEnvironment(
      'APP_ID',
      defaultValue: 'com.codesolution.balkans.delivery',
    );
    return TileLayer(
      urlTemplate: urlTemplate,
      userAgentPackageName: package,
      tileProvider: NetworkTileProvider(
        headers: <String, String>{
          'User-Agent': '${AppConfig.brandName} Delivery/1.0 ($package)',
        },
      ),
    );
  }
}
