import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'api_config.dart';

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

  Future<AppUser?> restoreSession() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final preferences = await SharedPreferences.getInstance();
    final savedUser = preferences.getString(_currentUserKey);
    _token = preferences.getString(_tokenKey);

    if (savedUser == null || _token == null || _token!.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(savedUser);
      final user = AppUser.fromJson(Map<String, Object?>.from(decoded as Map));
      _currentUser = user;
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
    final response = await _postAuth('/auth/signin', {
      'email': email,
      'password': password,
    });

    return _applyAuthResponse(response);
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _postAuth('/auth/register', {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });

    return _applyAuthResponse(response);
  }

  Future<void> signOut() async {
    _currentUser = null;
    _token = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserKey);
    await preferences.remove(_tokenKey);
  }

  Future<Map<String, Object?>> _postAuth(
    String path,
    Map<String, Object?> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final decoded = response.body.isEmpty
          ? <String, Object?>{}
          : Map<String, Object?>.from(jsonDecode(response.body) as Map);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthException(decoded['message'] as String? ?? 'Dang nhap that bai.');
      }

      return decoded;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('Khong ket noi duoc backend: $error');
    }
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
    await _saveSession(user, token);
    return user;
  }

  Future<void> _saveSession(AppUser user, String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
    await preferences.setString(_tokenKey, token);
  }
}
