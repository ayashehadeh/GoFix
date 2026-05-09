import 'package:equatable/equatable.dart';
import '../../domain/entities/availability_entity.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object> get props => [];
}

class LoadAvailability extends AvailabilityEvent {}

class SaveAvailabilityEvent extends AvailabilityEvent {
  final AvailabilityEntity availability;

  const SaveAvailabilityEvent({required this.availability});

  @override
  List<Object> get props => [availability];
}

class UpdateAvailabilityToggle extends AvailabilityEvent {
  final bool isAvailable;

  const UpdateAvailabilityToggle({required this.isAvailable});

  @override
  List<Object> get props => [isAvailable];
}

class UpdateWorkingDay extends AvailabilityEvent {
  final String day;
  final bool isSelected;

  const UpdateWorkingDay({required this.day, required this.isSelected});

  @override
  List<Object> get props => [day, isSelected];
}

class UpdateWorkingHours extends AvailabilityEvent {
  final int fromHour;
  final int fromMinute;
  final int toHour;
  final int toMinute;

  const UpdateWorkingHours({
    required this.fromHour,
    required this.fromMinute,
    required this.toHour,
    required this.toMinute,
  });

  @override
  List<Object> get props => [fromHour, fromMinute, toHour, toMinute];
}
