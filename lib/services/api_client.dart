import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final String _baseUrl = kIsWeb
      ? 'http://localhost:5256/api'
      : (Platform.isAndroid ? 'http://10.0.2.2:5256/api' : 'http://localhost:5256/api');

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
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
      // Not json
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded ?? body;
    }

    String errorMessage = 'Đã xảy ra lỗi (${response.statusCode})';
    if (decoded is Map && decoded.containsKey('message')) {
      errorMessage = decoded['message'].toString();
    } else if (decoded is Map && decoded.containsKey('errors')) {
      // Validation errors
      final errors = decoded['errors'];
      if (errors is Map) {
        errorMessage = errors.values.expand((e) => e as List).join('\n');
      }
    }

    throw ApiException(errorMessage, response.statusCode);
  }

  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static final List<Map<String, dynamic>> _mockSims = [
    {
      'id': 'sim-001',
      'phoneNumber': '0909 888 888',
      'carrier': 'Mobifone',
      'type': 'Sim lục quý',
      'price': 125000000,
      'meaning': 'Dãy 8 tượng trưng cho phát tài, phát lộc.',
      'status': 'Available',
      'description': 'Số dễ nhớ, phù hợp kinh doanh và xây dựng thương hiệu cá nhân.'
    },
    {
      'id': 'sim-002',
      'phoneNumber': '0986 686 868',
      'carrier': 'Viettel',
      'type': 'Sim lộc phát',
      'price': 28500000,
      'meaning': 'Cặp 68 và 86 mang ý nghĩa lộc phát luân chuyển.',
      'status': 'Available',
      'description': 'Cân bằng giữa độ đẹp, ngân sách và tính dễ đọc.'
    },
    {
      'id': 'sim-003',
      'phoneNumber': '0912 333 333',
      'carrier': 'Vinaphone',
      'type': 'Sim tam hoa',
      'price': 42000000,
      'meaning': 'Tam hoa 3 tạo cảm giác chắc chắn, bền vững.',
      'status': 'Available',
      'description': 'Phù hợp chủ shop, tư vấn viên và người làm dịch vụ cần số dễ nhớ.'
    },
    {
      'id': 'sim-004',
      'phoneNumber': '0888 197 1999',
      'carrier': 'Vietnamobile',
      'type': 'Sim năm sinh',
      'price': 9600000,
      'meaning': 'Gắn với năm sinh 1999, dễ tạo dấu ấn cá nhân.',
      'status': 'Sold',
      'description': 'Một lựa chọn cá nhân hóa, dễ nhớ khi giới thiệu.'
    },
    {
      'id': 'sim-005',
      'phoneNumber': '0901 444 444',
      'carrier': 'Viettel',
      'type': 'Sim tứ quý',
      'price': 65000000,
      'meaning': 'Tứ quý 4 tạo nhịp số đều, chắc và rất dễ ghi nhớ.',
      'status': 'Available',
      'description': 'Phù hợp người kinh doanh cần số hotline nổi bật.'
    },
    {
      'id': 'sim-006',
      'phoneNumber': '0937 797 979',
      'carrier': 'Mobifone',
      'type': 'Sim thần tài',
      'price': 18500000,
      'meaning': 'Cặp 79 tượng trưng cho thần tài, may mắn trong công việc.',
      'status': 'Available',
      'description': 'Dãy số có nhịp đọc đẹp, giá vừa phải.'
    },
    {
      'id': 'sim-007',
      'phoneNumber': '0999 555 555',
      'carrier': 'Gmobile',
      'type': 'Sim tam hoa',
      'price': 32000000,
      'meaning': 'Cụm 555 lặp lại tạo cảm giác cân bằng và dễ nhớ.',
      'status': 'Sold',
      'description': 'Số đẹp cho nhu cầu cá nhân hoặc cửa hàng nhỏ.'
    },
    {
      'id': 'sim-008',
      'phoneNumber': '0918 168 168',
      'carrier': 'Vinaphone',
      'type': 'Sim lộc phát',
      'price': 22000000,
      'meaning': 'Cặp 168 gợi ý nghĩa sinh lộc phát.',
      'status': 'Available',
      'description': 'Số có nhịp đọc mềm, dễ giới thiệu qua điện thoại.'
    }
  ];

  static final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'ORD-1001',
      'userId': 'user-customer',
      'simId': 'sim-002',
      'receiverName': 'Nguyễn Văn Khách',
      'receiverPhone': '0909000000',
      'address': 'Thành phố Hồ Chí Minh',
      'totalPrice': 28500000,
      'status': 'Pending',
      'createdAt': '2026-06-16T05:00:00Z',
      'note': 'Giao hàng giờ hành chính'
    },
    {
      'id': 'ORD-1002',
      'userId': 'user-customer',
      'simId': 'sim-004',
      'receiverName': 'Nguyễn Văn Khách',
      'receiverPhone': '0909000000',
      'address': 'Hà Nội',
      'totalPrice': 9600000,
      'status': 'Completed',
      'createdAt': '2026-06-15T09:00:00Z',
      'note': ''
    }
  ];

  dynamic _handleMockRequest(String method, String path, Object? body) {
    if (path.startsWith('/auth/signin')) {
      final map = body as Map<String, dynamic>? ?? {};
      final email = map['email'] ?? '';
      return {
        'token': 'mock-jwt-token',
        'user': {
          'id': 'user-customer',
          'fullName': email == 'admin@simdep.vn' ? 'Quản trị viên' : 'Nguyễn Văn Khách',
          'email': email,
          'phone': email == 'admin@simdep.vn' ? '0909999999' : '0909000000',
          'role': email == 'admin@simdep.vn' ? 'Admin' : 'Customer',
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
          'role': 'Customer',
        }
      };
    }

    if (path.startsWith('/sims')) {
      return _mockSims;
    }

    if (path.startsWith('/orders')) {
      if (method == 'POST') {
        final map = body as Map<String, dynamic>? ?? {};
        final newOrder = {
          'id': 'ORD-1003',
          'userId': map['userId'] ?? 'user-customer',
          'simId': map['simId'] ?? 'sim-001',
          'receiverName': map['receiverName'] ?? 'Nguyễn Văn Khách',
          'receiverPhone': map['receiverPhone'] ?? '0909000000',
          'address': map['address'] ?? 'Hà Nội',
          'totalPrice': map['totalPrice'] ?? 125000000,
          'status': 'Pending',
          'createdAt': DateTime.now().toIso8601String(),
          'note': map['note'] ?? '',
        };
        _mockOrders.add(newOrder);
        return newOrder;
      }
      return _mockOrders;
    }

    return null;
  }

  Future<dynamic> get(String path) async {
    if (_isTest) {
      return _handleMockRequest('GET', path, null);
    }
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$path'),
        headers: _getHeaders(),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Không thể kết nối tới máy chủ. Vui lòng kiểm tra lại kết nối mạng.', 500);
    }
  }

  Future<dynamic> post(String path, Object? body) async {
    if (_isTest) {
      return _handleMockRequest('POST', path, body);
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Không thể kết nối tới máy chủ. Vui lòng kiểm tra lại kết nối mạng.', 500);
    }
  }

  Future<dynamic> put(String path, Object? body) async {
    if (_isTest) {
      return _handleMockRequest('PUT', path, body);
    }
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$path'),
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Không thể kết nối tới máy chủ. Vui lòng kiểm tra lại kết nối mạng.', 500);
    }
  }

  Future<dynamic> delete(String path) async {
    if (_isTest) {
      return _handleMockRequest('DELETE', path, null);
    }
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$path'),
        headers: _getHeaders(),
      );
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Không thể kết nối tới máy chủ. Vui lòng kiểm tra lại kết nối mạng.', 500);
    }
  }
}
