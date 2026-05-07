import 'package:equatable/equatable.dart';

/// Domain entity representing a single day's working hours schedule.
/// Used by [SetWorkingHours] use case and the stepper UI.
class WorkingHoursSchedule extends Equatable {
  final String dayLabel; // e.g. "Sunday", "Monday"
  final String openTime;  // HH:mm  e.g. "08:00"
  final String closeTime; // HH:mm  e.g. "17:00"

  const WorkingHoursSchedule({
    required this.dayLabel,
    required this.openTime,
    required this.closeTime,
  });

  WorkingHoursSchedule copyWith({
    String? dayLabel,
    String? openTime,
    String? closeTime,
  }) {
    return WorkingHoursSchedule(
      dayLabel: dayLabel ?? this.dayLabel,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  /// Display label, e.g. "08:00 - 17:00"
  String get timeRange => '$openTime - $closeTime';

  @override
  List<Object?> get props => [dayLabel, openTime, closeTime];
}
