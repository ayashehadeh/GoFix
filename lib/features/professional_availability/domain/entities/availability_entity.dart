import 'package:equatable/equatable.dart';

class AvailabilityEntity extends Equatable {
  final bool isAvailable;
  final List<String> workingDays;
  final int fromHour;
  final int fromMinute;
  final int toHour;
  final int toMinute;

  const AvailabilityEntity({
    required this.isAvailable,
    required this.workingDays,
    required this.fromHour,
    required this.fromMinute,
    required this.toHour,
    required this.toMinute,
  });

  @override
  List<Object?> get props => [
        isAvailable,
        workingDays,
        fromHour,
        fromMinute,
        toHour,
        toMinute,
      ];
}
