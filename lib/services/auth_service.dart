import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

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

  final List<_AuthAccount> _accounts = [
    const _AuthAccount(
      user: AppUser(
        id: 'user-customer',
        fullName: 'Nguyễn Văn Khách',
        email: 'customer@simdep.vn',
        phone: '0909000000',
        role: UserRole.customer,
      ),
      password: '123456',
    ),
    const _AuthAccount(
      user: AppUser(
        id: 'user-admin',
        fullName: 'Quản trị viên',
        email: 'admin@simdep.vn',
        phone: '0909999999',
        role: UserRole.admin,
      ),
      password: 'admin123',
    ),
  ];

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (_currentUser != null) {
      return _currentUser;
    }

    final preferences = await SharedPreferences.getInstance();
    final savedUser = preferences.getString(_currentUserKey);
    if (savedUser == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(savedUser);
      final user = AppUser.fromJson(Map<String, Object?>.from(decoded as Map));
      _currentUser = user;
    } catch (_) {
      await preferences.remove(_currentUserKey);
      _currentUser = null;
    }

    return _currentUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final account = _findByEmail(email);
    if (account == null || account.password != password) {
      throw const AuthException('Email hoặc mật khẩu không đúng.');
    }

    _currentUser = account.user;
    await _saveSession(account.user);
    return account.user;
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (_findByEmail(email) != null) {
      throw const AuthException('Email này đã được sử dụng.');
    }

    final user = AppUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: UserRole.customer,
    );

    _accounts.add(_AuthAccount(user: user, password: password));
    _currentUser = user;
    await _saveSession(user);
    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserKey);
  }

  _AuthAccount? _findByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final account in _accounts) {
      if (account.user.email.toLowerCase() == normalizedEmail) {
        return account;
      }
    }
    return null;
  }

  Future<void> _saveSession(AppUser user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
  }
}

class _AuthAccount {
  const _AuthAccount({required this.user, required this.password});

  final AppUser user;
  final String password;
}
