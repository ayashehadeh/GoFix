import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/working_hours_schedule.dart';
import '../repositories/become_professional_repository.dart';

class SetWorkingHours {
  final BecomeProfessionalRepository repository;
  const SetWorkingHours(this.repository);

  Future<Either<Failure, Unit>> call(List<WorkingHoursSchedule> schedules) =>
      repository.setWorkingHours(schedules);
}
