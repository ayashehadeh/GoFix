import 'dart:convert';
import 'package:gp/core/storage/token_storage.dart';

class UserInfoHelper {
  static Future<String> getFullName() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return '';

      final parts = token.split('.');
      if (parts.length != 3) return '';

      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = json.decode(decoded) as Map<String, dynamic>;

      final first = map['first_name'] as String? ?? '';
      final last = map['last_name'] as String? ?? '';
      return '$first $last'.trim();
    } catch (_) {
      return '';
    }
  }
}