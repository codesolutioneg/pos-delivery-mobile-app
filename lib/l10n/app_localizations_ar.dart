// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String appTitle(String brand) {
    return 'توصيل $brand';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navWallet => 'المحفظة';

  @override
  String get navProfile => 'حسابي';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginTitle => 'تسجيل دخول السائق';

  @override
  String get loginSubtitle =>
      'سجّل الدخول باسم المستخدم وكلمة المرور من نقطة البيع';

  @override
  String get usernameLabel => 'اسم المستخدم / البريد';

  @override
  String get usernameHint => 'أدخل اسم المستخدم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get splashTagline => 'في الطريق إلى عميلك';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get driverId => 'معرّف السائق';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get phone => 'الموبايل';

  @override
  String get phoneNotSet => '— (غير مسجّل في نقطة البيع)';

  @override
  String get phoneHintProfile =>
      'رقم الموبايل يجيء من كارت السائق في نقطة البيع. لو فاضي، أضفه هناك ثم سجّل الدخول مرة أخرى.';

  @override
  String get waitingDispatch => 'في انتظار تعيين طلب…';

  @override
  String get waitingDispatchHint => 'الطلبات المعيّنة من نقطة البيع تظهر هنا.';

  @override
  String get restaurantFallback => 'المطعم';

  @override
  String get pickupLocationFallback => 'موقع الاستلام';

  @override
  String get deliverTo => 'التسليم إلى';

  @override
  String get address => 'العنوان';

  @override
  String get addressMissing => 'لا يوجد عنوان';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String autoRejectSeconds(int seconds) {
    return 'رفض تلقائي خلال $seconds ث';
  }

  @override
  String get customer => 'العميل';

  @override
  String get items => 'الأصناف';

  @override
  String get total => 'الإجمالي';

  @override
  String get collect => 'للتحصيل';

  @override
  String get status => 'الحالة';

  @override
  String get payment => 'الدفع';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get reject => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String orderNumber(String id) {
    return 'طلب $id';
  }

  @override
  String get ctaWaitingCashier => 'في انتظار إغلاق الكاشير';

  @override
  String get ctaReachedCustomer => 'وصلت للعميل — تم التسليم';

  @override
  String get ctaReachedRestaurant => 'وصلت للمطعم — استلام الطلب';

  @override
  String get pickupTitle => 'الطلب جاهز للاستلام';

  @override
  String get pickupSubtitle => 'استلم الطلب وقم بتوصيله إلى العميل.';

  @override
  String get itemsAndPickup => 'الأصناف ومكان الاستلام';

  @override
  String get pickupRoute => 'مسار الاستلام والتسليم';

  @override
  String get pickedUpStartDelivery => 'استلمت الطلب — أبدأ التوصيل';

  @override
  String get statusUpdatedOnTheWay => 'تم تحديث الحالة: في الطريق';

  @override
  String get callCustomer => 'اتصال بالعميل';

  @override
  String get orderItems => 'أصناف الطلب';

  @override
  String get markDelivered => 'تم التسليم للعميل';

  @override
  String get markedDelivered => 'تم التسليم — الحالة: delivered';

  @override
  String get chatComingSoon => 'المحادثة قريباً — استخدم الاتصال حالياً';

  @override
  String get ordersActive => 'نشطة';

  @override
  String get ordersCompleted => 'مكتملة';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get orderNotFound => 'الطلب غير موجود';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get goToPickup => 'استلمت الطلب — Pickup';

  @override
  String get walletBalance => 'الرصيد المتاح';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get noWalletTx => 'لا توجد معاملات بعد';

  @override
  String get noWalletTxHint =>
      'الأرباح والمدفوعات ستظهر هنا عند ربط واجهة المحفظة.';

  @override
  String get mapArea => 'منطقة الخريطة';

  @override
  String get mapHotRestartHint =>
      'أوقف التطبيق وشغّله من جديد لتحميل خرائط جوجل.';

  @override
  String get cannotOpenDialer => 'تعذر فتح تطبيق الاتصال';

  @override
  String callFailed(String error) {
    return 'فشل الاتصال: $error';
  }

  @override
  String get paymentCash => 'الدفع عند الاستلام';

  @override
  String get paymentDash => '—';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get chooseProject => 'اختر المشروع';

  @override
  String activeOrders(int count) {
    return '$count طلبات نشطة';
  }

  @override
  String orderChip(String id) {
    return '$id';
  }

  @override
  String get mapYouMarker => 'موقعك';

  @override
  String get mapCustomerMarker => 'العميل';

  @override
  String get mapLocatingCustomer => 'جاري تحديد موقع العميل…';

  @override
  String get mapCustomerNotFound =>
      'تعذر وضع العميل على الخريطة من هذا العنوان.';

  @override
  String get mapApproximateHint => 'موقع تقريبي من العنوان — تأكد عند الوصول.';

  @override
  String get mapRouteToCustomer => 'للعميل';

  @override
  String get mapRouteCalculating => 'جاري حساب المسار…';

  @override
  String mapRouteMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String mapRouteHoursMinutes(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String mapRouteDistanceKm(String km) {
    return '$km كم';
  }

  @override
  String mapRouteDistanceMeters(int meters) {
    return '$meters م';
  }

  @override
  String get mapRouteEstimateTag => 'تقريبي';
}
