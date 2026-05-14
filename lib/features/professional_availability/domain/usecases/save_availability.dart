import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/availability_entity.dart';
import '../repositories/availability_repository.dart';

// ── Save Working Hours ────────────────────────────────────────────────────────

class SaveWorkingHours implements UseCase<void, SaveWorkingHoursParams> {
  final AvailabilityRepository repository;

  SaveWorkingHours(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveWorkingHoursParams params) async {
    return await repository.saveWorkingHours(params.schedules);
  }
}

class SaveWorkingHoursParams extends Equatable {
  final List<DaySchedule> schedules;

  const SaveWorkingHoursParams({required this.schedules});

  @override
  List<Object?> get props => [schedules];
}

// ── Toggle Availability ───────────────────────────────────────────────────────

class ToggleAvailability implements UseCase<void, ToggleAvailabilityParams> {
  final AvailabilityRepository repository;

  ToggleAvailability(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleAvailabilityParams params) async {
    return await repository.toggleAvailability(
        isAvailable: params.isAvailable);
  }
}

class ToggleAvailabilityParams extends Equatable {
  final bool isAvailable;

  const ToggleAvailabilityParams({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}