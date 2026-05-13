import 'package:equatable/equatable.dart';
import '../../domain/entities/availability_entity.dart';

abstract class AvailabilityState extends Equatable {
  const AvailabilityState();

  @override
  List<Object?> get props => [];
}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final bool isAvailable;

  /// Key = full day name e.g. "Monday"
  /// Value = DaySchedule if it's a working day, null if day off
  final Map<String, DaySchedule?> schedules;

  const AvailabilityLoaded({
    required this.isAvailable,
    required this.schedules,
  });

  /// Whether a day is currently selected as a working day
  bool isWorkingDay(String day) => schedules[day] != null;

  /// Get schedule for a day — null if not a working day
  DaySchedule? scheduleFor(String day) => schedules[day];

  AvailabilityLoaded copyWith({
    bool? isAvailable,
    Map<String, DaySchedule?>? schedules,
  }) {
    return AvailabilityLoaded(
      isAvailable: isAvailable ?? this.isAvailable,
      schedules: schedules ?? this.schedules,
    );
  }

  /// Extracts only the working days as a List<DaySchedule> for saving
  List<DaySchedule> get workingSchedules => schedules.values
      .whereType<DaySchedule>()
      .toList();

  @override
  List<Object?> get props => [isAvailable, schedules];
}

// Shown while the toggle API call is in-flight
class AvailabilityTogglingAvailability extends AvailabilityLoaded {
  const AvailabilityTogglingAvailability({
    required super.isAvailable,
    required super.schedules,
  });
}

// Shown while the save schedules API call is in-flight
class AvailabilitySaving extends AvailabilityLoaded {
  const AvailabilitySaving({
    required super.isAvailable,
    required super.schedules,
  });
}

class AvailabilitySaved extends AvailabilityLoaded {
  const AvailabilitySaved({
    required super.isAvailable,
    required super.schedules,
  });
}

class AvailabilityError extends AvailabilityState {
  final String message;

  const AvailabilityError({required this.message});

  @override
  List<Object?> get props => [message];
}