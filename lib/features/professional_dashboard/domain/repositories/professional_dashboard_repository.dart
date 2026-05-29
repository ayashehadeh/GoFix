import 'package:dartz/dartz.dart';
import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';
import '../entities/dashboard_stats_entity.dart';

abstract class ProfessionalDashboardRepository {
  Future<Either<String, DashboardStatsEntity>> getDashboardStats();
  Future<Either<String, List<ProJob>>> getIncomingRequests();
  Future<Either<String, List<ProJob>>> getScheduledJobs();
  Future<Either<String, void>> acceptJobRequest(String jobId);
  Future<Either<String, void>> declineJobRequest(String jobId);
  Future<Either<String, void>> updateJobStatus(String jobId, String status);
  Future<Either<String, void>> cancelJob(String jobId, {String? reason});
}
