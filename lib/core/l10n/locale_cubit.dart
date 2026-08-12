import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app language (ar / en). User switches from Profile.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._prefs) : super(_read(_prefs));

  static const String _key = 'app_locale_code';

  final SharedPreferences _prefs;

  static Locale _read(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    if (code == 'en') return const Locale('en');
    // Default Arabic for local market until user changes it.
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_key, locale.languageCode);
    emit(locale);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(next);
  }
}
