import 'dart:convert';
import 'package:gp/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoHelper {
  static const String _displayNameKey = 'display_name_override';

  /// Persists a locally-updated display name so that profile headers and the
  /// dashboard show the new value immediately without waiting for a JWT refresh.
  static Future<void> setDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name);
  }

  static Future<String> getFullName() async {
    try {
      // Prefer the locally-cached value set after a name update.
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_displayNameKey);
      if (cached != null && cached.isNotEmpty) return cached;

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

  static Future<String> getEmail() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return '';

      final parts = token.split('.');
      if (parts.length != 3) return '';

      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = json.decode(decoded) as Map<String, dynamic>;

      return map['email'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }
}