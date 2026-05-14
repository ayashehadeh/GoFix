import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/availability_model.dart';

abstract class AvailabilityLocalDataSource {
  Future<AvailabilityModel?> getCachedAvailability();
  Future<void> cacheAvailability(AvailabilityModel availability);
  Future<void> clearCache();
}

class AvailabilityLocalDataSourceImpl implements AvailabilityLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cacheKey = 'professional_availability';

  AvailabilityLocalDataSourceImpl({required this.sharedPreferences});

  // Returns null if nothing cached yet — caller decides the default.
  @override
  Future<AvailabilityModel?> getCachedAvailability() async {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString == null) return null;
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return AvailabilityModel.fromJson(jsonMap);
  }

  @override
  Future<void> cacheAvailability(AvailabilityModel availability) async {
    await sharedPreferences.setString(
      _cacheKey,
      jsonEncode(availability.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cacheKey);
  }
}