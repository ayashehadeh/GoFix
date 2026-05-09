import 'package:dartz/dartz.dart';
import '../entities/job_entity.dart';
import '../entities/dashboard_stats_entity.dart';

abstract class ProfessionalDashboardRepository {
  /// Get dashboard statistics (requests, scheduled, completed counts)
  Future<Either<String, DashboardStatsEntity>> getDashboardStats();

  /// Get incoming job requests
  Future<Either<String, List<JobEntity>>> getIncomingRequests();

  /// Get scheduled jobs
  Future<Either<String, List<JobEntity>>> getScheduledJobs();

  /// Accept a job request
  Future<Either<String, void>> acceptJobRequest(String jobId);

  /// Decline a job request
  Future<Either<String, void>> declineJobRequest(String jobId);

  /// Update job status
  Future<Either<String, void>> updateJobStatus(String jobId, String status);
}
