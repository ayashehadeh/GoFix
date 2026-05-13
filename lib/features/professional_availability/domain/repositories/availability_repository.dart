import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/availability_entity.dart';

abstract class AvailabilityRepository {
  /// Fetches working hours + isAvailable from the API.
  /// Falls back to local cache if network fails.
  Future<Either<Failure, AvailabilityEntity>> getAvailability();

  /// Saves all working hour schedules to the API.
  /// PUT /professionals/profile/working-hours
  Future<Either<Failure, void>> saveWorkingHours(List<DaySchedule> schedules);

  /// Toggles the professional's overall availability on/off.
  /// PUT /professionals/profile/availability
  Future<Either<Failure, void>> toggleAvailability({required bool isAvailable});
}