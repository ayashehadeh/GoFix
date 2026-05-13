import '../../domain/entities/availability_entity.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.isAvailable,
    required super.schedules,
  });

  // Maps from backend GET /professionals/profile/working-hours response:
  // {
  //   "isAvailable": true,
  //   "schedules": [
  //     { "day": "Monday", "openTime": "08:00", "closeTime": "17:00" },
  //     ...
  //   ]
  // }
  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    final rawSchedules = json['schedules'] as List? ?? [];
    return AvailabilityModel(
      isAvailable: json['isAvailable'] as bool? ?? false,
      schedules: rawSchedules
          .map((e) => DaySchedule(
                day: e['day'] as String? ?? e['dayLabel'] as String? ?? '',
                openTime: e['openTime'] as String? ?? '',
                closeTime: e['closeTime'] as String? ?? '',
              ))
          .toList(),
    );
  }

  // Used for local cache (SharedPreferences) — same shape as backend for consistency
  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'schedules': schedules
          .map((s) => {
                'day': s.day,
                'openTime': s.openTime,
                'closeTime': s.closeTime,
              })
          .toList(),
    };
  }

  factory AvailabilityModel.fromEntity(AvailabilityEntity entity) {
    return AvailabilityModel(
      isAvailable: entity.isAvailable,
      schedules: entity.schedules,
    );
  }
}