import 'package:dartz/dartz.dart';
import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';
import '../entities/dashboard_stats_entity.dart';
import '../repositories/professional_dashboard_repository.dart';

class GetDashboardStats {
  final ProfessionalDashboardRepository repository;

  GetDashboardStats(this.repository);

  Future<Either<String, DashboardStatsEntity>> call() async {
    return await repository.getDashboardStats();
  }
}

class GetIncomingRequests {
  final ProfessionalDashboardRepository repository;

  GetIncomingRequests(this.repository);

  Future<Either<String, List<ProJob>>> call() async {
    return await repository.getIncomingRequests();
  }
}

class GetScheduledJobs {
  final ProfessionalDashboardRepository repository;

  GetScheduledJobs(this.repository);

  Future<Either<String, List<ProJob>>> call() async {
    return await repository.getScheduledJobs();
  }
}

class AcceptJobRequest {
  final ProfessionalDashboardRepository repository;

  AcceptJobRequest(this.repository);

  Future<Either<String, void>> call(String jobId) async {
    return await repository.acceptJobRequest(jobId);
  }
}

class DeclineJobRequest {
  final ProfessionalDashboardRepository repository;

  DeclineJobRequest(this.repository);

  Future<Either<String, void>> call(String jobId) async {
    return await repository.declineJobRequest(jobId);
  }
}

class UpdateJobStatus {
  final ProfessionalDashboardRepository repository;

  UpdateJobStatus(this.repository);

  Future<Either<String, void>> call(String jobId, String status) async {
    return await repository.updateJobStatus(jobId, status);
  }
}

class CancelJobProfessional {
  final ProfessionalDashboardRepository repository;

  CancelJobProfessional(this.repository);

  Future<Either<String, void>> call(String jobId, {String? reason}) =>
      repository.cancelJob(jobId, reason: reason);
}
