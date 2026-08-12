/// Centralized asset paths for the driver app.
abstract final class AppAssets {
  AppAssets._();

  /// Active brand logo. Populated per branch by `scripts/apply_brand.ps1`
  /// (copies `deploy_configs/<brand>/icon.png` here), same as the customer app.
  static const String brandLogo = 'brand_assets/active/icon.png';

  static const String orderPickup = 'assets/images/order_pickup.gif';
  static const String locationOrange = 'assets/images/location_orange3x.png';
  static const String locationBlack = 'assets/images/location_black3x.png';
}
