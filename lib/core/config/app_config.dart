/// White-label / API configuration for the driver app.
///
/// One codebase, one brand per build:
///   flutter run \
///     --dart-define=BASE_URL=https://api.example.com/api \
///     --dart-define=BRAND_ID=balkans \
///     --dart-define=BRAND_NAME=Balkans \
///     --dart-define=RESTAURANT_KEY=xxx \
///     --dart-define=PRIMARY_COLOR=0xFF1A237E
abstract final class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.dishflow.code-solution.org/api',
  );

  static const String apiPrefix = '/v1';

  static const String brandId = String.fromEnvironment(
    'BRAND_ID',
    defaultValue: 'balkans',
  );

  static const String brandName = String.fromEnvironment(
    'BRAND_NAME',
    defaultValue: 'Balkans',
  );

  static const String restaurantKey = String.fromEnvironment(
    'RESTAURANT_KEY',
    defaultValue: 'dk_demo_balkans_restaurant_key_0000000000000001',
  );

  static const int primaryColorValue = int.fromEnvironment(
    'PRIMARY_COLOR',
    defaultValue: 0xFFFF6B35,
  );

  /// Key for the Routes API web service (driver → customer route + ETA).
  ///
  /// Defaults to the Maps key already in AndroidManifest.xml, but that key is
  /// restricted to Android apps, and web-service calls from Dio carry no
  /// Android package/cert — Google answers API_KEY_ANDROID_APP_BLOCKED. Pass an
  /// unrestricted (or IP-restricted) key to get real road routes:
  ///   --dart-define=MAPS_API_KEY=...
  /// Without it the app falls back to a straight-line ETA estimate.
  static const String mapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'AIzaSyAfwQoYKL5MsjapdhXX68fBQIKW9St6iO0',
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 2;

  /// GPS write interval to RTDB `driver_locations/{uid}`.
  static const Duration gpsInterval = Duration(seconds: 5);
}
