import 'package:equatable/equatable.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

// Load working hours + isAvailable from API
class LoadAvailability extends AvailabilityEvent {}

// Toggle the isAvailable switch — fires API immediately
class ToggleAvailabilityEvent extends AvailabilityEvent {
  final bool isAvailable;

  const ToggleAvailabilityEvent({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

// Toggle a day on/off — if turning on, adds a default schedule for that day
//                       if turning off, removes that day's schedule entirely
class ToggleWorkingDay extends AvailabilityEvent {
  final String day; // Full name: "Monday", "Tuesday", etc.

  const ToggleWorkingDay({required this.day});

  @override
  List<Object?> get props => [day];
}

// Update open/close time for a specific day
class UpdateDaySchedule extends AvailabilityEvent {
  final String day;       // Full name: "Monday", etc.
  final String openTime;  // "HH:mm"
  final String closeTime; // "HH:mm"

  const UpdateDaySchedule({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  @override
  List<Object?> get props => [day, openTime, closeTime];
}

// Save all schedules to API
class SaveWorkingHoursEvent extends AvailabilityEvent {}