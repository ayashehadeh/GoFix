import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/pro_job.dart';
import '../repositories/professional_jobs_repository.dart';

class GetUpcomingJobs {
  final ProfessionalJobsRepository repository;
  const GetUpcomingJobs(this.repository);

  Future<Either<Failure, List<ProJob>>> call() =>
      repository.getUpcomingJobs();
}

class GetPastJobs {
  final ProfessionalJobsRepository repository;
  const GetPastJobs(this.repository);

  Future<Either<Failure, List<ProJob>>> call() =>
      repository.getPastJobs();
}

class UpdateProJobStatus {
  final ProfessionalJobsRepository repository;
  const UpdateProJobStatus(this.repository);

  Future<Either<Failure, ProJob>> call({
    required String jobId,
    required ProJobStatus newStatus,
  }) =>
      repository.updateJobStatus(jobId: jobId, newStatus: newStatus);
}
