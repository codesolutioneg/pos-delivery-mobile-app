import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Resolves this branch's `X-Restaurant-Key` at **runtime** from its Firebase
/// project id.
///
/// The branch is chosen at runtime (debug branch picker / the baked
/// `firebase_options` in release), but `AppConfig.restaurantKey` is a
/// compile-time `String.fromEnvironment`. Those two disagreed: running on the
/// `odc-chat` project while the binary carried the **balkans** key made
/// `POST /drivers/login` look up the username under the wrong restaurant and
/// answer `UNAUTHORIZED — Invalid username or password`, which reads exactly
/// like a wrong password. Resolving the key from
/// `Firebase.app().options.projectId` makes it follow the branch instead.
///
/// `POST /tenant/firebase-key` is public (no key, no token) and rate-limited to
/// 10 requests / 15 min per IP, so the answer is cached per project id.
class RestaurantKeyProvider {
  /// [projectIdResolver] exists so tests can supply a branch without booting
  /// Firebase; production leaves it null and reads the live Firebase app.
  RestaurantKeyProvider({Dio? dio, String? Function()? projectIdResolver})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: '${AppConfig.baseUrl}${AppConfig.apiPrefix}',
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                headers: const {'Content-Type': 'application/json'},
                validateStatus: (_) => true,
              ),
            ),
        _projectIdResolver = projectIdResolver;

  final Dio _dio;
  final String? Function()? _projectIdResolver;

  static const String _keyPrefix = 'dishflow_restaurant_key_';
  static const String _namePrefix = 'dishflow_restaurant_name_';

  /// In-memory cache, keyed by project id so switching branch cannot serve a
  /// stale key from the previous project.
  final Map<String, String> _memory = <String, String>{};

  /// The active branch's Firebase project id — the branch identity.
  String? get projectId {
    final override = _projectIdResolver;
    if (override != null) return override();
    try {
      return Firebase.app().options.projectId;
    } catch (_) {
      return null;
    }
  }

  /// Restaurant key for the active branch.
  ///
  /// Order: memory → SharedPreferences → `POST /tenant/firebase-key` →
  /// `AppConfig.restaurantKey` as a last resort. The last resort is kept so a
  /// branded release build keeps working if the endpoint is unreachable, but it
  /// is the value that caused the mismatch above, so it is logged loudly.
  Future<String> resolve({bool forceRefresh = false}) async {
    final id = projectId;
    if (id == null || id.isEmpty) {
      return AppConfig.restaurantKey;
    }

    if (!forceRefresh) {
      final cached = _memory[id];
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final prefs = await SharedPreferences.getInstance();
    final prefsKey = '$_keyPrefix$id';

    if (!forceRefresh) {
      final stored = prefs.getString(prefsKey);
      if (stored != null && stored.isNotEmpty) {
        _memory[id] = stored;
        return stored;
      }
    }

    final fetched = await _fetch(id);
    if (fetched != null) {
      _memory[id] = fetched.key;
      await prefs.setString(prefsKey, fetched.key);
      if (fetched.restaurantName.isNotEmpty) {
        await prefs.setString('$_namePrefix$id', fetched.restaurantName);
      }
      debugPrint('[key] $id -> ${fetched.restaurantName}');
      return fetched.key;
    }

    debugPrint(
      '[key] could not resolve a key for project "$id" — falling back to the '
      'compile-time AppConfig.restaurantKey. If it belongs to another '
      'restaurant, every login will fail with "Invalid username or password".',
    );
    return AppConfig.restaurantKey;
  }

  /// Drops the cached key for the active branch (e.g. after
  /// `RESTAURANT_KEY_INVALID`).
  Future<void> invalidate() async {
    final id = projectId;
    if (id == null || id.isEmpty) return;
    _memory.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$id');
  }

  /// Restaurant name that came with the key — for display only.
  Future<String?> restaurantName() async {
    final id = projectId;
    if (id == null || id.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_namePrefix$id');
  }

  Future<_ResolvedKey?> _fetch(String projectId) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/tenant/firebase-key',
        data: {'firebaseProjectId': projectId},
      );
      final body = res.data;
      if (res.statusCode != 200 || body?['success'] != true) {
        final code = ((body?['error'] as Map?)?['code'] ?? '').toString();
        debugPrint('[key] /tenant/firebase-key ${res.statusCode} $code');
        return null;
      }
      final data = (body?['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final key = (data['apiKey'] ?? '').toString();
      if (key.isEmpty) return null;
      return _ResolvedKey(
        key: key,
        restaurantName: (data['restaurantName'] ?? '').toString(),
      );
    } on DioException catch (e) {
      debugPrint('[key] /tenant/firebase-key transport error: ${e.message}');
      return null;
    }
  }
}

class _ResolvedKey {
  const _ResolvedKey({required this.key, required this.restaurantName});

  final String key;
  final String restaurantName;
}
