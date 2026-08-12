import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// This app's package name + signing certificate SHA-1, read from Android.
class AndroidAppIdentity {
  const AndroidAppIdentity({required this.packageName, required this.sha1});

  final String packageName;
  final String sha1;
}

/// Supplies the headers an Android-restricted Google API key requires.
///
/// A key restricted to Android apps rejects web-service calls unless the request
/// carries `X-Android-Package` and `X-Android-Cert`. The Maps SDK adds them
/// itself; Dio does not, so we read the same values over a MethodChannel.
///
/// Note this only satisfies the *application* restriction. The key must also
/// allow the API being called, or Google answers `API_KEY_SERVICE_BLOCKED`.
abstract final class AndroidApiKeyHeaders {
  AndroidApiKeyHeaders._();

  static const MethodChannel _channel =
      MethodChannel('org.codesolution.dishflow_delivery/app_identity');

  static AndroidAppIdentity? _cached;
  static bool _resolved = false;

  /// Empty on non-Android platforms, or when the identity cannot be read.
  static Future<Map<String, String>> headers() async {
    final AndroidAppIdentity? identity = await _identity();
    if (identity == null) {
      return const <String, String>{};
    }
    return <String, String>{
      'X-Android-Package': identity.packageName,
      'X-Android-Cert': identity.sha1,
    };
  }

  static Future<AndroidAppIdentity?> _identity() async {
    if (_resolved) {
      return _cached;
    }
    if (!Platform.isAndroid) {
      _resolved = true;
      return null;
    }

    try {
      final Map<Object?, Object?>? raw = await _channel
          .invokeMapMethod<Object?, Object?>('getSigningIdentity');
      final String? packageName = raw?['packageName'] as String?;
      final String? sha1 = raw?['sha1'] as String?;
      if (packageName != null &&
          packageName.isNotEmpty &&
          sha1 != null &&
          sha1.isNotEmpty) {
        _cached = AndroidAppIdentity(packageName: packageName, sha1: sha1);
      }
    } on PlatformException {
      // Fall through: no headers, key must be unrestricted instead.
    } on MissingPluginException {
      // Host side not wired (e.g. an old engine); same fallback.
    }

    _resolved = true;
    return _cached;
  }
}
