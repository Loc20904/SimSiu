import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
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
      _token = null;
      ApiClient.instance.setToken(null);
      return null;
    }

    try {
      final decoded = jsonDecode(savedUser);
      final user = AppUser.fromJson(Map<String, Object?>.from(decoded as Map));
      _currentUser = user;
      _token = token;
      ApiClient.instance.setToken(token);
    } catch (_) {
      await preferences.remove(_currentUserKey);
      await preferences.remove(_tokenKey);
      _currentUser = null;
      _token = null;
      ApiClient.instance.setToken(null);
    }

    return _currentUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post('/auth/signin', body: {
        'email': email.trim(),
        'password': password,
      });

      return _applyAuthResponse(Map<String, Object?>.from(response as Map));
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post('/auth/register', body: {
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
      });

      return _applyAuthResponse(Map<String, Object?>.from(response as Map));
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    ApiClient.instance.setToken(null);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserKey);
    await preferences.remove(_tokenKey);
  }

  Future<AppUser> _applyAuthResponse(Map<String, Object?> response) async {
    final token = response['token'] as String?;
    final userJson = response['user'];

    if (token == null || userJson is! Map) {
      throw const AuthException('Phan hoi dang nhap khong hop le.');
    }

    final user = AppUser.fromJson(Map<String, Object?>.from(userJson));
    _currentUser = user;
    _token = token;
    ApiClient.instance.setToken(token);
    await _saveSession(user, token);
    return user;
  }

  Future<void> _saveSession(AppUser user, String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
    await preferences.setString(_tokenKey, token);
  }
}
