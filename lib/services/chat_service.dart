import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat'),
        headers: AuthService.instance.authHeaders,
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['reply'] as String;
      } else {
        final errorBody = jsonDecode(response.body);
        return errorBody['message'] ?? 'Lỗi không xác định từ máy chủ (Mã lỗi: ${response.statusCode})';
      }
    } catch (e) {
      debugPrint('Error sending chat message: $e');
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng hoặc thử lại sau.';
    }
  }
}
