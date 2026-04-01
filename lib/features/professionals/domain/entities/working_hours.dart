import 'package:equatable/equatable.dart';

class DaySchedule extends Equatable {
  final String day; // e.g. "Sunday - Thursday" or "Saturday"
  final String openTime;  // e.g. "8:00 AM"
  final String closeTime; // e.g. "8:00 PM"

  const DaySchedule({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  /// e.g. "8:00 AM - 8:00 PM"
  String get timeRange => '$openTime - $closeTime';

  @override
  List<Object> get props => [day, openTime, closeTime];
}

class WorkingHours extends Equatable {
  final List<DaySchedule> schedules;

  const WorkingHours({required this.schedules});

  @override
  List<Object> get props => [schedules];
}
