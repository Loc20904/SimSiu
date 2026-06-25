import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  Future<Map<String, Object?>> post(
    String path, {
    required Map<String, Object?> body,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = AuthService.instance.token;
      if (token == null || token.isEmpty) {
        throw const ApiException('Ban can dang nhap truoc khi tiep tuc.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(response.body) as Map);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['message'] as String? ?? 'Yeu cau API that bai.');
    }

    return decoded;
  }

  Future<List<Object?>> getList(String path) async {
    final token = AuthService.instance.token;
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const ApiException('Khong tai duoc du lieu tu API.');
    }

    return jsonDecode(response.body) as List<Object?>;
  }

  Future<Map<String, Object?>> getObject(String path) async {
    final token = AuthService.instance.token;
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    final decoded = response.body.isEmpty
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(response.body) as Map);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['message'] as String? ?? 'Khong tai duoc du lieu tu API.');
    }

    return decoded;
  }

  Future<void> put(
    String path, {
    required Map<String, Object?> body,
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = AuthService.instance.token;
      if (token == null || token.isEmpty) {
        throw const ApiException('Ban can dang nhap truoc khi tiep tuc.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = response.body.isEmpty
          ? <String, Object?>{}
          : Map<String, Object?>.from(jsonDecode(response.body) as Map);
      throw ApiException(decoded['message'] as String? ?? 'Yeu cau API that bai.');
    }
  }

  Future<void> delete(String path, {bool requiresAuth = true}) async {
    final headers = <String, String>{};

    if (requiresAuth) {
      final token = AuthService.instance.token;
      if (token == null || token.isEmpty) {
        throw const ApiException('Ban can dang nhap truoc khi tiep tuc.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = response.body.isEmpty
          ? <String, Object?>{}
          : Map<String, Object?>.from(jsonDecode(response.body) as Map);
      throw ApiException(decoded['message'] as String? ?? 'Yeu cau API that bai.');
    }
  }
}
