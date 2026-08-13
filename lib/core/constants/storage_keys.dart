/// Secure storage keys for the driver app.
abstract final class StorageKeys {
  StorageKeys._();

  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String firebaseCustomToken = 'firebase_custom_token';
  static const String driverId = 'driver_id';
  static const String driverName = 'driver_name';
  static const String driverPhone = 'driver_phone';
  static const String driverUsername = 'driver_username';
  static const String branchId = 'branch_id';
  static const String localeCode = 'app_locale_code';
}
