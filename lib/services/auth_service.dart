import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_config.dart';
import '../models/app_user.dart';
import 'order_service.dart';

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
    final savedUser = preferences.getString(_currentUserKey);
    final savedToken = preferences.getString(_tokenKey);

    if (savedUser == null || savedToken == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(savedUser);
      final user = AppUser.fromJson(Map<String, Object?>.from(decoded as Map));
      _currentUser = user;
      _token = savedToken;
    } catch (_) {
      await preferences.remove(_currentUserKey);
      await preferences.remove(_tokenKey);
      _currentUser = null;
      _token = null;
    }

    return _currentUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final decodedBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw AuthException(decodedBody['message'] ?? 'Đăng nhập thất bại.');
      }

      final token = decodedBody['token'] as String;
      final userJson = decodedBody['user'] as Map<String, dynamic>;
      final user = AppUser.fromJson(userJson);

      _currentUser = user;
      _token = token;

      await _saveSession(user, token);
      
      // Load orders for the signed in user
      await OrderService.instance.fetchOrders(userId: user.id);

      return user;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Không thể kết nối đến máy chủ: $e');
    }
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.trim(),
          'password': password,
        }),
      );

      final decodedBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw AuthException(decodedBody['message'] ?? 'Đăng ký thất bại.');
      }

      final token = decodedBody['token'] as String;
      final userJson = decodedBody['user'] as Map<String, dynamic>;
      final user = AppUser.fromJson(userJson);

      _currentUser = user;
      _token = token;

      await _saveSession(user, token);

      // Load orders for the newly registered user
      await OrderService.instance.fetchOrders(userId: user.id);

      return user;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Không thể kết nối đến máy chủ: $e');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserKey);
    await preferences.remove(_tokenKey);
    OrderService.instance.clearOrders();
  }

  Future<void> _saveSession(AppUser user, String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
    await preferences.setString(_tokenKey, token);
  }
}
