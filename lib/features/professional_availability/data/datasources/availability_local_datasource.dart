import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/availability_model.dart';

abstract class AvailabilityLocalDataSource {
  Future<AvailabilityModel> getAvailability();
  Future<void> saveAvailability(AvailabilityModel availability);
}

class AvailabilityLocalDataSourceImpl implements AvailabilityLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _availabilityKey = 'professional_availability';

  AvailabilityLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AvailabilityModel> getAvailability() async {
    final jsonString = sharedPreferences.getString(_availabilityKey);

    if (jsonString == null) {
      // Return default availability if nothing saved
      return const AvailabilityModel(
        isAvailable: true,
        workingDays: [],
        fromHour: 7,
        fromMinute: 0,
        toHour: 13,
        toMinute: 0,
      );
    }

    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return AvailabilityModel.fromJson(jsonMap);
  }

  @override
  Future<void> saveAvailability(AvailabilityModel availability) async {
    final jsonString = jsonEncode(availability.toJson());
    await sharedPreferences.setString(_availabilityKey, jsonString);
  }
}
