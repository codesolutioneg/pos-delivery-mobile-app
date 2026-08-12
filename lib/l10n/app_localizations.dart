import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'{brand} Delivery'**
  String appTitle(String brand);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the username & password from POS'**
  String get loginSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username / Email'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get usernameHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'On the way to your customer'**
  String get splashTagline;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @driverId.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverId;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNotSet.
  ///
  /// In en, this message translates to:
  /// **'— (not set in POS)'**
  String get phoneNotSet;

  /// No description provided for @phoneHintProfile.
  ///
  /// In en, this message translates to:
  /// **'Phone comes from the driver card in POS. If empty, add it there and log in again.'**
  String get phoneHintProfile;

  /// No description provided for @waitingDispatch.
  ///
  /// In en, this message translates to:
  /// **'Waiting for dispatch…'**
  String get waitingDispatch;

  /// No description provided for @waitingDispatchHint.
  ///
  /// In en, this message translates to:
  /// **'Assigned orders from POS appear here.'**
  String get waitingDispatchHint;

  /// No description provided for @restaurantFallback.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantFallback;

  /// No description provided for @pickupLocationFallback.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocationFallback;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressMissing.
  ///
  /// In en, this message translates to:
  /// **'No address provided'**
  String get addressMissing;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @autoRejectSeconds.
  ///
  /// In en, this message translates to:
  /// **'Auto-reject {seconds} s'**
  String autoRejectSeconds(int seconds);

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order {id}'**
  String orderNumber(String id);

  /// No description provided for @ctaWaitingCashier.
  ///
  /// In en, this message translates to:
  /// **'Waiting for cashier close'**
  String get ctaWaitingCashier;

  /// No description provided for @ctaReachedCustomer.
  ///
  /// In en, this message translates to:
  /// **'Reached customer — Mark delivered'**
  String get ctaReachedCustomer;

  /// No description provided for @ctaReachedRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Reached restaurant — Pickup'**
  String get ctaReachedRestaurant;

  /// No description provided for @pickupTitle.
  ///
  /// In en, this message translates to:
  /// **'Order ready to pickup'**
  String get pickupTitle;

  /// No description provided for @pickupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up the order and deliver to the customer.'**
  String get pickupSubtitle;

  /// No description provided for @itemsAndPickup.
  ///
  /// In en, this message translates to:
  /// **'Items & pickup'**
  String get itemsAndPickup;

  /// No description provided for @pickupRoute.
  ///
  /// In en, this message translates to:
  /// **'Pickup & drop-off'**
  String get pickupRoute;

  /// No description provided for @pickedUpStartDelivery.
  ///
  /// In en, this message translates to:
  /// **'Order received — Start delivery'**
  String get pickedUpStartDelivery;

  /// No description provided for @statusUpdatedOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Status updated: on the way'**
  String get statusUpdatedOnTheWay;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call customer'**
  String get callCustomer;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get orderItems;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered to customer'**
  String get markDelivered;

  /// No description provided for @markedDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered — status: delivered'**
  String get markedDelivered;

  /// No description provided for @chatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat coming soon — use Call for now'**
  String get chatComingSoon;

  /// No description provided for @ordersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersActive;

  /// No description provided for @ordersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersCompleted;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders'**
  String get noOrders;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @goToPickup.
  ///
  /// In en, this message translates to:
  /// **'Order received — Pickup'**
  String get goToPickup;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get walletBalance;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @noWalletTx.
  ///
  /// In en, this message translates to:
  /// **'No wallet transactions yet'**
  String get noWalletTx;

  /// No description provided for @noWalletTxHint.
  ///
  /// In en, this message translates to:
  /// **'Earnings and payouts will show here when the wallet API is connected.'**
  String get noWalletTxHint;

  /// No description provided for @mapArea.
  ///
  /// In en, this message translates to:
  /// **'Map area'**
  String get mapArea;

  /// No description provided for @mapHotRestartHint.
  ///
  /// In en, this message translates to:
  /// **'Stop the app & Run again (full rebuild) to load Google Maps.'**
  String get mapHotRestartHint;

  /// No description provided for @cannotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Cannot open dialer'**
  String get cannotOpenDialer;

  /// No description provided for @callFailed.
  ///
  /// In en, this message translates to:
  /// **'Call failed: {error}'**
  String callFailed(String error);

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get paymentCash;

  /// No description provided for @paymentDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get paymentDash;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @chooseProject.
  ///
  /// In en, this message translates to:
  /// **'Choose project'**
  String get chooseProject;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} active orders'**
  String activeOrders(int count);

  /// No description provided for @orderChip.
  ///
  /// In en, this message translates to:
  /// **'{id}'**
  String orderChip(String id);

  /// No description provided for @mapYouMarker.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get mapYouMarker;

  /// No description provided for @mapCustomerMarker.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get mapCustomerMarker;

  /// No description provided for @mapLocatingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Finding customer location…'**
  String get mapLocatingCustomer;

  /// No description provided for @mapCustomerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not place customer on the map from this address.'**
  String get mapCustomerNotFound;

  /// No description provided for @mapApproximateHint.
  ///
  /// In en, this message translates to:
  /// **'Approximate location from address — confirm on arrival.'**
  String get mapApproximateHint;

  /// No description provided for @mapRouteToCustomer.
  ///
  /// In en, this message translates to:
  /// **'To the customer'**
  String get mapRouteToCustomer;

  /// No description provided for @mapRouteCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating route…'**
  String get mapRouteCalculating;

  /// No description provided for @mapRouteMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String mapRouteMinutes(int minutes);

  /// No description provided for @mapRouteHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String mapRouteHoursMinutes(int hours, int minutes);

  /// No description provided for @mapRouteDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String mapRouteDistanceKm(String km);

  /// No description provided for @mapRouteDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String mapRouteDistanceMeters(int meters);

  /// No description provided for @mapRouteEstimateTag.
  ///
  /// In en, this message translates to:
  /// **'approx.'**
  String get mapRouteEstimateTag;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
