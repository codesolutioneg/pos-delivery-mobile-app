// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String appTitle(String brand) {
    return '$brand Delivery';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navOrders => 'Orders';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navProfile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginTitle => 'Driver Login';

  @override
  String get loginSubtitle => 'Sign in with the username & password from POS';

  @override
  String get usernameLabel => 'Username / Email';

  @override
  String get usernameHint => 'Enter username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get loginButton => 'Log in';

  @override
  String get splashTagline => 'On the way to your customer';

  @override
  String get logout => 'Log out';

  @override
  String get driverId => 'Driver ID';

  @override
  String get username => 'Username';

  @override
  String get phone => 'Phone';

  @override
  String get phoneNotSet => '— (not set in POS)';

  @override
  String get phoneHintProfile =>
      'Phone comes from the driver card in POS. If empty, add it there and log in again.';

  @override
  String get waitingDispatch => 'Waiting for dispatch…';

  @override
  String get waitingDispatchHint => 'Assigned orders from POS appear here.';

  @override
  String get restaurantFallback => 'Restaurant';

  @override
  String get pickupLocationFallback => 'Pickup location';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get address => 'Address';

  @override
  String get addressMissing => 'No address provided';

  @override
  String get newOrder => 'New order';

  @override
  String autoRejectSeconds(int seconds) {
    return 'Auto-reject $seconds s';
  }

  @override
  String get customer => 'Customer';

  @override
  String get items => 'Items';

  @override
  String get total => 'Total';

  @override
  String get collect => 'Collect';

  @override
  String get status => 'Status';

  @override
  String get payment => 'Payment';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String orderNumber(String id) {
    return 'Order $id';
  }

  @override
  String get ctaWaitingCashier => 'Waiting for cashier close';

  @override
  String get ctaReachedCustomer => 'Reached customer — Mark delivered';

  @override
  String get ctaReachedRestaurant => 'Reached restaurant — Pickup';

  @override
  String get pickupTitle => 'Order ready to pickup';

  @override
  String get pickupSubtitle => 'Pick up the order and deliver to the customer.';

  @override
  String get itemsAndPickup => 'Items & pickup';

  @override
  String get pickupRoute => 'Pickup & drop-off';

  @override
  String get pickedUpStartDelivery => 'Order received — Start delivery';

  @override
  String get statusUpdatedOnTheWay => 'Status updated: on the way';

  @override
  String get callCustomer => 'Call customer';

  @override
  String get orderItems => 'Order items';

  @override
  String get markDelivered => 'Delivered to customer';

  @override
  String get markedDelivered => 'Delivered — status: delivered';

  @override
  String get chatComingSoon => 'Chat coming soon — use Call for now';

  @override
  String get ordersActive => 'Active';

  @override
  String get ordersCompleted => 'Completed';

  @override
  String get noOrders => 'No orders';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderDetails => 'Order details';

  @override
  String get goToPickup => 'Order received — Pickup';

  @override
  String get walletBalance => 'Available balance';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get noWalletTx => 'No wallet transactions yet';

  @override
  String get noWalletTxHint =>
      'Earnings and payouts will show here when the wallet API is connected.';

  @override
  String get mapArea => 'Map area';

  @override
  String get mapHotRestartHint =>
      'Stop the app & Run again (full rebuild) to load Google Maps.';

  @override
  String get cannotOpenDialer => 'Cannot open dialer';

  @override
  String callFailed(String error) {
    return 'Call failed: $error';
  }

  @override
  String get paymentCash => 'Cash on delivery';

  @override
  String get paymentDash => '—';

  @override
  String get retry => 'Retry';

  @override
  String get chooseProject => 'Choose project';

  @override
  String activeOrders(int count) {
    return '$count active orders';
  }

  @override
  String orderChip(String id) {
    return '$id';
  }

  @override
  String get mapYouMarker => 'You';

  @override
  String get mapCustomerMarker => 'Customer';

  @override
  String get mapLocatingCustomer => 'Finding customer location…';

  @override
  String get mapCustomerNotFound =>
      'Could not place customer on the map from this address.';

  @override
  String get mapApproximateHint =>
      'Approximate location from address — confirm on arrival.';

  @override
  String get mapRouteToCustomer => 'To the customer';

  @override
  String get mapRouteCalculating => 'Calculating route…';

  @override
  String mapRouteMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String mapRouteHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String mapRouteDistanceKm(String km) {
    return '$km km';
  }

  @override
  String mapRouteDistanceMeters(int meters) {
    return '$meters m';
  }

  @override
  String get mapRouteEstimateTag => 'approx.';
}
