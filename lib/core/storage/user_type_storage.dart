import 'package:shared_preferences/shared_preferences.dart';

class UserTypeStorage {
  static const String _isProfessionalKey = 'is_professional';
  static const String _professionalNameKey = 'professional_name';

  // Save that user is now a professional
  static Future<void> setAsProfessional(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProfessionalKey, true);
    await prefs.setString(_professionalNameKey, name);
  }

  // Check if user is a professional
  static Future<bool> isProfessional() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProfessionalKey) ?? false;
  }

  // Get professional name
  static Future<String> getProfessionalName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_professionalNameKey) ?? 'Professional';
  }

  // Clear professional status (for logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isProfessionalKey);
    await prefs.remove(_professionalNameKey);
  }
}
