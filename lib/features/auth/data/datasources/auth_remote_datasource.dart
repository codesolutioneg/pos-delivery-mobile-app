import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/driver_auth_routes.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../domain/entities/driver_entity.dart';

/// Backend JWT login + Firebase Anonymous Auth (for `drivers/{uid}/orders`).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._storage, this._dioClient);

  final FlutterSecureStorage _storage;
  final DioClient _dioClient;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Dio get _dio => _dioClient.client;

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

  DriverEntity _entityFromApi(Map<String, dynamic> data) {
    final firebaseId = (data['firebaseDriverId'] ?? '').toString().trim();
    final id = firebaseId.isNotEmpty ? firebaseId : (data['id'] ?? '').toString();
    return DriverEntity(
      id: id,
      name: (data['name'] ?? data['username'] ?? id).toString(),
      username: (data['username'] ?? '').toString(),
      phone: () {
        final raw = data['phone']?.toString().trim();
        if (raw == null || raw.isEmpty) return null;
        return raw;
      }(),
      branchId: data['branchId']?.toString(),
    );
  }

  Future<void> _persist(
    DriverEntity driver,
    String accessToken, {
    String? refreshToken,
  }) async {
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
    if (driver.branchId != null && driver.branchId!.isNotEmpty) {
      await _storage.write(key: StorageKeys.branchId, value: driver.branchId);
    }
    await _storage.write(key: StorageKeys.authToken, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Exception _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final message = body is Map<String, dynamic>
        ? (body['error'] is Map<String, dynamic>
            ? body['error']['message'] as String?
            : body['message'] as String?)
        : null;
    if (status == 401) {
      return AuthException(message ?? 'Invalid username or password');
    }
    return ServerException(message ?? 'Request failed. Please try again.');
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
      final res = await _dio.post<Map<String, dynamic>>(
        DriverAuthRoutes.login,
        data: {'username': userKey, 'password': password},
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Login failed. Please try again.');
      }
      final token = (data['accessToken'] ?? '').toString();
      final refresh = (data['refreshToken'] ?? '').toString();
      final driverJson = data['driver'];
      if (token.isEmpty || driverJson is! Map<String, dynamic>) {
        throw const ServerException('Login failed. Please try again.');
      }
      final driver = _entityFromApi(driverJson);
      if (driver.id.isEmpty) {
        throw const ServerException('Driver profile is missing a Firebase id.');
      }
      await _persist(driver, token, refreshToken: refresh);
      return driver;
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<DriverEntity?> readCachedDriver() async {
    final id = await _storage.read(key: StorageKeys.driverId);
    final token = await _storage.read(key: StorageKeys.authToken);
    if (id == null ||
        id.isEmpty ||
        token == null ||
        token.isEmpty ||
        token == 'firestore_driver') {
      return null;
    }
    try {
      await _ensureAnonAuth();
    } catch (_) {
      return null;
    }

    try {
      final res = await _dio.get<Map<String, dynamic>>(DriverAuthRoutes.me);
      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        final driver = _entityFromApi(data);
        await _persist(driver, token);
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

  Future<void> logout() async {
    final refresh = await _storage.read(key: StorageKeys.refreshToken);
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _dio.post<Map<String, dynamic>>(
          DriverAuthRoutes.logout,
          data: {'refreshToken': refresh},
        );
      } catch (_) {
        // Local sign-out still proceeds if the API is unreachable.
      }
    }
    await clearSession();
  }

  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.authToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.firebaseCustomToken);
    await _storage.delete(key: StorageKeys.driverId);
    await _storage.delete(key: StorageKeys.driverName);
    await _storage.delete(key: StorageKeys.driverPhone);
    await _storage.delete(key: StorageKeys.driverUsername);
    await _storage.delete(key: StorageKeys.branchId);
    await _auth.signOut();
  }
}
