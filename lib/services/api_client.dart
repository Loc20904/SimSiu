import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode = 500]);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Map<String, String> _headers({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    } else if (requiresAuth) {
      throw ApiException('Ban can dang nhap truoc khi tiep tuc.', 401);
    }

    return headers;
  }

  dynamic _processResponse(http.Response response) {
    final body = response.body;
    dynamic decoded;
    try {
      if (body.isNotEmpty) {
        decoded = jsonDecode(body);
      }
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded ?? body;
    }

    var errorMessage = 'Da xay ra loi (${response.statusCode})';
    if (decoded is Map && decoded.containsKey('message')) {
      errorMessage = decoded['message'].toString();
    } else if (decoded is Map && decoded.containsKey('errors')) {
      final errors = decoded['errors'];
      if (errors is Map) {
        errorMessage = errors.values.expand((e) => e as List).join('\n');
      }
    }

    throw ApiException(errorMessage, response.statusCode);
  }

  static final List<Map<String, dynamic>> _mockSims = [
    {
      'id': 'sim-001',
      'phoneNumber': '0909 888 888',
      'carrier': 'Mobifone',
      'type': 'Sim luc quy',
      'price': 125000000,
      'meaning': 'Day 8 tuong trung cho phat tai, phat loc.',
      'status': 'Available',
      'description': 'So de nho, phu hop kinh doanh.'
    },
  ];

  dynamic _handleMockRequest(String method, String path, Object? body) {
    if (path.startsWith('/auth/signin')) {
      final map = body as Map<String, dynamic>? ?? {};
      final email = map['email']?.toString() ?? '';
      return {
        'token': 'mock-jwt-token',
        'user': {
          'id': email == 'admin@simdep.vn' ? 'user-admin' : 'user-customer',
          'fullName': email == 'admin@simdep.vn' ? 'Quan tri vien' : 'Nguyen Van Khach',
          'email': email,
          'phone': email == 'admin@simdep.vn' ? '0909999999' : '0909000000',
          'role': email == 'admin@simdep.vn' ? 'admin' : 'customer',
        }
      };
    }

    if (path.startsWith('/auth/register')) {
      final map = body as Map<String, dynamic>? ?? {};
      return {
        'token': 'mock-jwt-token',
        'user': {
          'id': 'user-customer-new',
          'fullName': map['fullName'] ?? 'Tran Van Test',
          'email': map['email'] ?? 'test@example.com',
          'phone': map['phone'] ?? '0901234567',
          'role': 'customer',
        }
      };
    }

    if (path.startsWith('/sims')) {
      return _mockSims;
    }

    if (path.startsWith('/payments/payos/orders')) {
      return {
        'orderId': '',
        'payOsOrderCode': 123456789,
        'paymentLinkId': 'mock-payment-link',
        'checkoutUrl': 'https://pay.payos.vn/web/mock',
        'qrCode': '',
      };
    }

    if (path.startsWith('/payments/payos/pending')) {
      return [];
    }

    return null;
  }

  Future<dynamic> get(String path) async {
    if (_isTest) {
      return _handleMockRequest('GET', path, null);
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(),
      );
      return _processResponse(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Khong the ket noi toi may chu.', 500);
    }
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    bool requiresAuth = false,
  }) async {
    if (_isTest) {
      return _handleMockRequest('POST', path, body);
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Khong the ket noi toi may chu.', 500);
    }
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool requiresAuth = true,
  }) async {
    if (_isTest) {
      return _handleMockRequest('PUT', path, body);
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Khong the ket noi toi may chu.', 500);
    }
  }

  Future<dynamic> delete(String path, {bool requiresAuth = true}) async {
    if (_isTest) {
      return _handleMockRequest('DELETE', path, null);
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: _headers(requiresAuth: requiresAuth),
      );
      return _processResponse(response);
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Khong the ket noi toi may chu.', 500);
    }
  }

  Future<List<Object?>> getList(String path) async {
    final response = await get(path);
    return List<Object?>.from(response as List);
  }

  Future<Map<String, Object?>> getObject(String path) async {
    final response = await get(path);
    return Map<String, Object?>.from(response as Map);
  }
}
