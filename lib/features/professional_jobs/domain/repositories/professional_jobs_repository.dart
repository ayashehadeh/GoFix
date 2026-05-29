import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/pro_job.dart';

abstract class ProfessionalJobsRepository {
  Future<Either<Failure, List<ProJob>>> getUpcomingJobs();
  Future<Either<Failure, List<ProJob>>> getPastJobs();
  Future<Either<Failure, ProJob>> updateJobStatus({
    required String jobId,
    required ProJobStatus newStatus,
  });
  Future<Either<Failure, void>> cancelJob(String jobId, {String? reason});
}
