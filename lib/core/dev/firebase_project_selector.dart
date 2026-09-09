// DEV-ONLY Firebase project switcher (same client list as POS).
// Debug `flutter run` only — TestFlight/release is Balkans (baked firebase_options).
// ignore_for_file: depend_on_referenced_packages, library_prefixes

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_configs/balkans_madente/firebase_options.dart'
    as cfgBalkMadente;
import '../../firebase_configs/balkanz_gym/firebase_options.dart' as cfgGym;
import '../../firebase_configs/balkanz_nasr/firebase_options.dart' as cfgNasr;
import '../../firebase_configs/balkanz_zayed/firebase_options.dart' as cfgZayed;
import '../../firebase_configs/balkns_sahel_one/firebase_options.dart'
    as cfgBalkSahelOne;
import '../../firebase_configs/balkns_sahel_two/firebase_options.dart'
    as cfgBalkSahelTwo;
import '../../firebase_configs/cai_gardennasrcity/firebase_options.dart'
    as cfgGarden;
import '../../firebase_configs/cai_madenty/firebase_options.dart' as cfgCai;
import '../../firebase_configs/cai_sahel_one/firebase_options.dart'
    as cfgCaiSahelOne;
import '../../firebase_configs/cai_sahel_two/firebase_options.dart'
    as cfgCaiSahelTwo;
import '../../firebase_configs/cai_sawspark/firebase_options.dart'
    as cfgSawspark;
import '../../firebase_configs/cai_straubmall/firebase_options.dart'
    as cfgStraub;
import '../../firebase_configs/dev/firebase_options.dart' as cfgDev;

const String kDevFirebaseClientPrefKey = '_dev_firebase_client';

/// Same keys/labels as POS `devClients`.
const Map<String, String> kDevFirebaseClients = {
  'dev': 'Dev / Test (odc-chat)',
  'cai_madenty': 'Cairo Caizir — مدينتي',
  'balkanz_gym': 'Balkanz Gym — الجيم',
  'balkanz_nasr': 'Balkanz Nasr — مدينة نصر',
  'balkanz_zayed': 'Balkanz Zayed — زايد',
  'balkns_sahel_one': 'Balkanz Sahel — فرع واحد',
  'balkns_sahel_two': 'Balkanz Sahel — فرع اتنين',
  'cai_sahel_one': 'Cairo Sahel — فرع واحد',
  'cai_sahel_two': 'Cairo Sahel — فرع اتنين',
  'balkans_madente': 'Balkanz — مدينتي',
  'cai_gardennasrcity': 'Cairo Garden — مدينة نصر',
  'cai_sawspark': 'Cairo Sawspark',
  'cai_straubmall': 'Cairo Straub Mall',
};

FirebaseOptions? firebaseOptionsForClient(String client) {
  switch (client) {
    case 'dev':
      return cfgDev.DefaultFirebaseOptions.currentPlatform;
    case 'cai_madenty':
      return cfgCai.DefaultFirebaseOptions.currentPlatform;
    case 'balkanz_gym':
      return cfgGym.DefaultFirebaseOptions.currentPlatform;
    case 'balkanz_nasr':
      return cfgNasr.DefaultFirebaseOptions.currentPlatform;
    case 'balkanz_zayed':
      return cfgZayed.DefaultFirebaseOptions.currentPlatform;
    case 'balkns_sahel_one':
      return cfgBalkSahelOne.DefaultFirebaseOptions.currentPlatform;
    case 'balkns_sahel_two':
      return cfgBalkSahelTwo.DefaultFirebaseOptions.currentPlatform;
    case 'cai_sahel_one':
      return cfgCaiSahelOne.DefaultFirebaseOptions.currentPlatform;
    case 'cai_sahel_two':
      return cfgCaiSahelTwo.DefaultFirebaseOptions.currentPlatform;
    case 'balkans_madente':
      return cfgBalkMadente.DefaultFirebaseOptions.currentPlatform;
    case 'cai_gardennasrcity':
      return cfgGarden.DefaultFirebaseOptions.currentPlatform;
    case 'cai_sawspark':
      return cfgSawspark.DefaultFirebaseOptions.currentPlatform;
    case 'cai_straubmall':
      return cfgStraub.DefaultFirebaseOptions.currentPlatform;
    default:
      return null;
  }
}

Future<String?> getStoredFirebaseClient() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(kDevFirebaseClientPrefKey);
}

Future<void> saveFirebaseClient(String clientId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kDevFirebaseClientPrefKey, clientId);
}

/// Result of trying to activate Firebase options.
enum FirebaseInitResult {
  /// App was initialized (or already on the same project).
  ready,

  /// Different project selected while default app exists — restart required
  /// (Android cannot delete the default Firebase app).
  restartRequired,
}

/// Initializes Firebase when nothing is running yet.
///
/// If a *different* project is requested while the default app already exists,
/// returns [FirebaseInitResult.restartRequired] — caller must save prefs and
/// cold-restart the process (POS does the same via reload / hot-restart).
Future<FirebaseInitResult> initializeFirebaseForOptions(
  FirebaseOptions options,
) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: options);
    return FirebaseInitResult.ready;
  }

  final existing = Firebase.app().options.projectId;
  if (existing == options.projectId) {
    return FirebaseInitResult.ready;
  }

  return FirebaseInitResult.restartRequired;
}

/// In release: baked [DefaultFirebaseOptions]. In debug: stored client or null.
Future<FirebaseOptions?> resolveStartupFirebaseOptions({
  required FirebaseOptions releaseFallback,
}) async {
  if (kReleaseMode) return releaseFallback;
  final stored = await getStoredFirebaseClient();
  if (stored == null || stored.isEmpty) return null;
  return firebaseOptionsForClient(stored) ?? releaseFallback;
}
