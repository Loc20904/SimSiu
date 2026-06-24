import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../models/app_user.dart';
import 'order_service.dart';
import 'api_client.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const _currentUserKey = 'auth.currentUser';
  static const _tokenKey = 'auth.token';

  AppUser? _currentUser;
  String? _token;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<AppUser?> restoreSession() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    final savedUser = preferences.getString(_currentUserKey);

    if (token == null || savedUser == null) {
      _currentUser = null;
      ApiClient.instance.setToken(null);
      return null;
    }

    try {
      final decoded = jsonDecode(savedUser);
      final user = AppUser.fromJson(Map<String, Object?>.from(decoded as Map));
      _currentUser = user;
      ApiClient.instance.setToken(token);
    } catch (_) {
      await preferences.remove(_currentUserKey);
      await preferences.remove(_tokenKey);
      _currentUser = null;
      ApiClient.instance.setToken(null);
    }

    return _currentUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final responseBody = await ApiClient.instance.post('/auth/signin', {
        'email': email.trim(),
        'password': password,
      });

      final token = responseBody['token'] as String;
      final userJson = responseBody['user'] as Map<String, dynamic>;
      final user = AppUser.fromJson(Map<String, Object?>.from(userJson));

      _currentUser = user;
      
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenKey, token);
      await preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
      
      ApiClient.instance.setToken(token);
      return user;
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Đăng nhập thất bại: $e');
    }
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final responseBody = await ApiClient.instance.post('/auth/register', {
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
      });

      final token = responseBody['token'] as String;
      final userJson = responseBody['user'] as Map<String, dynamic>;
      final user = AppUser.fromJson(Map<String, Object?>.from(userJson));

      _currentUser = user;

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tokenKey, token);
      await preferences.setString(_currentUserKey, jsonEncode(user.toJson()));

      ApiClient.instance.setToken(token);
      return user;
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Đăng ký thất bại: $e');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    ApiClient.instance.setToken(null);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserKey);
    await preferences.remove(_tokenKey);
  }
}
