import 'package:equatable/equatable.dart';

/// A single day's working hours schedule.
/// Matches the backend WorkingHoursRequest/WorkingHoursDto shape.
class DaySchedule extends Equatable {
  final String day;       // Full name: "Sunday", "Monday", etc.
  final String openTime;  // 24-hour "HH:mm" e.g. "08:00"
  final String closeTime; // 24-hour "HH:mm" e.g. "17:00"

  const DaySchedule({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  DaySchedule copyWith({
    String? day,
    String? openTime,
    String? closeTime,
  }) {
    return DaySchedule(
      day: day ?? this.day,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  @override
  List<Object?> get props => [day, openTime, closeTime];
}

class AvailabilityEntity extends Equatable {
  final bool isAvailable;

  /// Each entry is one working day with its own open/close times.
  /// Only days the professional works are included (no entry = day off).
  final List<DaySchedule> schedules;

  const AvailabilityEntity({
    required this.isAvailable,
    required this.schedules,
  });

  /// Ordered list of all days for UI display purposes.
  static const List<String> orderedDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Short labels matching the ordered days above (for day chips in UI).
  static const List<String> shortDayLabels = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  /// Returns the schedule for a given full day name, or null if not a working day.
  DaySchedule? scheduleFor(String day) {
    try {
      return schedules.firstWhere((s) => s.day == day);
    } catch (_) {
      return null;
    }
  }

  /// Whether this day is currently a working day.
  bool isWorkingDay(String day) => scheduleFor(day) != null;

  AvailabilityEntity copyWith({
    bool? isAvailable,
    List<DaySchedule>? schedules,
  }) {
    return AvailabilityEntity(
      isAvailable: isAvailable ?? this.isAvailable,
      schedules: schedules ?? this.schedules,
    );
  }

  @override
  List<Object?> get props => [isAvailable, schedules];
}