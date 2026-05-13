import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AvailabilityStorage {
  static const String _availabilityKey = 'professional_availability';

  /// Save availability data
  static Future<void> saveAvailability({
    required bool isAvailable,
    required List<String> workingDays,
    required int fromHour,
    required int fromMinute,
    required int toHour,
    required int toMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'isAvailable': isAvailable,
      'workingDays': workingDays,
      'fromHour': fromHour,
      'fromMinute': fromMinute,
      'toHour': toHour,
      'toMinute': toMinute,
    };

    await prefs.setString(_availabilityKey, jsonEncode(data));
    print('💾 Saved availability: $data');
  }

  /// Get availability data
  static Future<Map<String, dynamic>?> getAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_availabilityKey);

    if (jsonString == null) {
      print('📋 No availability saved yet');
      return null;
    }

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    print('📋 Loaded availability: $data');
    return data;
  }

  /// Check if professional is currently available
  static Future<bool> isAvailable() async {
    final data = await getAvailability();
    return data?['isAvailable'] ?? false;
  }

  /// Clear availability data
  static Future<void> clearAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_availabilityKey);
    print('🗑️ Cleared availability');
  }
}
