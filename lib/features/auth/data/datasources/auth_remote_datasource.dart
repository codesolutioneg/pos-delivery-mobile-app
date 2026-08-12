import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/driver_entity.dart';

/// TEMP insecure login: match POS `drivers.username` + `drivers.password`.
/// Requires Firebase Anonymous Auth enabled (to satisfy Firestore rules).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._storage);

  final FlutterSecureStorage _storage;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _ensureAnonAuth() async {
    if (_auth.currentUser != null) return;
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed' ||
          e.code == 'admin-restricted-operation') {
        throw const AuthException(
          'Anonymous Auth disabled. Enable it in Firebase Console → '
          'Authentication → Sign-in method → Anonymous.',
        );
      }
      throw AuthException('Auth failed (${e.code}): ${e.message}');
    }
  }

  String? _phoneFrom(Map<String, dynamic> data) {
    final raw = data['phone'] ??
        data['mobile'] ??
        data['phoneNumber'] ??
        data['phone_number'] ??
        data['driver_phone'];
    final s = raw?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  DriverEntity _entityFromDoc(
    String id,
    Map<String, dynamic> data, {
    String? fallbackUsername,
  }) {
    return DriverEntity(
      id: id,
      name: (data['name'] ?? fallbackUsername ?? id).toString(),
      username: (data['username'] ?? fallbackUsername ?? '').toString(),
      phone: _phoneFrom(data),
      branchId: data['branchId']?.toString() ?? data['branch_id']?.toString(),
    );
  }

  Future<void> _persist(DriverEntity driver) async {
    await _storage.write(key: StorageKeys.driverId, value: driver.id);
    await _storage.write(key: StorageKeys.driverName, value: driver.name);
    await _storage.write(
      key: StorageKeys.driverUsername,
      value: driver.username,
    );
    await _storage.write(
      key: StorageKeys.driverPhone,
      value: driver.phone ?? '',
    );
    await _storage.write(key: StorageKeys.authToken, value: 'firestore_driver');
  }

  Future<DriverEntity> login({
    required String username,
    required String password,
  }) async {
    final userKey = username.trim();
    if (userKey.isEmpty || password.isEmpty) {
      throw const AuthException('Username and password are required');
    }

    try {
      await _ensureAnonAuth();

      final snap = await _db.collection('drivers').get();
      QueryDocumentSnapshot<Map<String, dynamic>>? match;
      for (final doc in snap.docs) {
        final data = doc.data();
        final u = (data['username'] ?? '').toString().trim();
        final p = (data['password'] ?? '').toString();
        final active = data['isActive'] != false;
        if (!active) continue;
        if (u == userKey && p == password) {
          match = doc;
          break;
        }
      }

      if (match == null) {
        throw AuthException(
          'Invalid username or password '
          '(checked ${snap.docs.length} drivers on this Firebase project).',
        );
      }

      final driver = _entityFromDoc(
        match.id,
        match.data(),
        fallbackUsername: userKey,
      );
      await _persist(driver);
      return driver;
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthException(
          'Firestore permission-denied on drivers. '
          'Deploy rules allowing authenticated read, or sign-in failed.',
        );
      }
      throw ServerException('${e.code}: ${e.message ?? 'Firestore error'}');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<DriverEntity?> readCachedDriver() async {
    final id = await _storage.read(key: StorageKeys.driverId);
    final token = await _storage.read(key: StorageKeys.authToken);
    if (id == null || id.isEmpty || token == null || token.isEmpty) {
      return null;
    }
    try {
      await _ensureAnonAuth();
    } catch (_) {
      return null;
    }

    // Prefer live Firestore profile so phone/username stay fresh.
    try {
      final doc = await _db.collection('drivers').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final driver = _entityFromDoc(id, doc.data()!);
        await _persist(driver);
        return driver;
      }
    } catch (_) {
      // Fall through to cache.
    }

    final name = await _storage.read(key: StorageKeys.driverName);
    final phone = await _storage.read(key: StorageKeys.driverPhone);
    final username = await _storage.read(key: StorageKeys.driverUsername);
    return DriverEntity(
      id: id,
      name: name ?? id,
      username: username ?? '',
      phone: (phone == null || phone.isEmpty) ? null : phone,
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.firebaseCustomToken);
    await _storage.delete(key: StorageKeys.driverId);
    await _storage.delete(key: StorageKeys.driverName);
    await _storage.delete(key: StorageKeys.driverPhone);
    await _storage.delete(key: StorageKeys.driverUsername);
    await _storage.delete(key: StorageKeys.branchId);
    await _auth.signOut();
  }
}
