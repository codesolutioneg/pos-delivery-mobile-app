import 'package:flutter/foundation.dart';

/// Holds the splash screen until BOTH conditions are met:
///   * the intro animation has had its minimum airtime, and
///   * the first auth state has settled (so we know where to go next).
///
/// Once [done] flips true it latches — later `AuthLoading` states (e.g. the
/// user tapping "Log in") must not bounce the app back to the splash.
class SplashGate extends ChangeNotifier {
  SplashGate({Duration minimumDuration = const Duration(milliseconds: 2400)}) {
    Future<void>.delayed(minimumDuration, () {
      _minElapsed = true;
      _settleIfReady();
    });
  }

  bool _minElapsed = false;
  bool _authSettled = false;
  bool _done = false;

  bool get done => _done;

  /// Called once the first real auth state arrives.
  void markAuthSettled() {
    if (_authSettled) return;
    _authSettled = true;
    _settleIfReady();
  }

  void _settleIfReady() {
    if (_done || !_minElapsed || !_authSettled) return;
    _done = true;
    notifyListeners();
  }
}
