import 'package:equatable/equatable.dart';

abstract class AvailabilityState extends Equatable {
  const AvailabilityState();

  @override
  List<Object> get props => [];
}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final bool isAvailable;
  final Map<String, bool> selectedDays;
  final int fromHour;
  final int fromMinute;
  final int toHour;
  final int toMinute;

  const AvailabilityLoaded({
    required this.isAvailable,
    required this.selectedDays,
    required this.fromHour,
    required this.fromMinute,
    required this.toHour,
    required this.toMinute,
  });

  @override
  List<Object> get props => [
        isAvailable,
        selectedDays,
        fromHour,
        fromMinute,
        toHour,
        toMinute,
      ];

  AvailabilityLoaded copyWith({
    bool? isAvailable,
    Map<String, bool>? selectedDays,
    int? fromHour,
    int? fromMinute,
    int? toHour,
    int? toMinute,
  }) {
    return AvailabilityLoaded(
      isAvailable: isAvailable ?? this.isAvailable,
      selectedDays: selectedDays ?? this.selectedDays,
      fromHour: fromHour ?? this.fromHour,
      fromMinute: fromMinute ?? this.fromMinute,
      toHour: toHour ?? this.toHour,
      toMinute: toMinute ?? this.toMinute,
    );
  }
}

class AvailabilitySaving extends AvailabilityState {}

class AvailabilitySaved extends AvailabilityState {}

class AvailabilityError extends AvailabilityState {
  final String message;

  const AvailabilityError({required this.message});

  @override
  List<Object> get props => [message];
}
