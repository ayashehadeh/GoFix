import '../../domain/entities/availability_entity.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.isAvailable,
    required super.workingDays,
    required super.fromHour,
    required super.fromMinute,
    required super.toHour,
    required super.toMinute,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      isAvailable: json['isAvailable'] as bool? ?? true,
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fromHour: json['fromHour'] as int? ?? 7,
      fromMinute: json['fromMinute'] as int? ?? 0,
      toHour: json['toHour'] as int? ?? 13,
      toMinute: json['toMinute'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'workingDays': workingDays,
      'fromHour': fromHour,
      'fromMinute': fromMinute,
      'toHour': toHour,
      'toMinute': toMinute,
    };
  }

  factory AvailabilityModel.fromEntity(AvailabilityEntity entity) {
    return AvailabilityModel(
      isAvailable: entity.isAvailable,
      workingDays: entity.workingDays,
      fromHour: entity.fromHour,
      fromMinute: entity.fromMinute,
      toHour: entity.toHour,
      toMinute: entity.toMinute,
    );
  }
}
