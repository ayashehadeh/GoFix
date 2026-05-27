import 'package:dartz/dartz.dart';
import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/professional_dashboard_repository.dart';
import '../datasources/professional_dashboard_remote_datasource.dart';

class ProfessionalDashboardRepositoryImpl
    implements ProfessionalDashboardRepository {
  final ProfessionalDashboardRemoteDataSource remoteDataSource;

  ProfessionalDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, DashboardStatsEntity>> getDashboardStats() async {
    try {
      final stats = await remoteDataSource.getDashboardStats();
      return Right(stats);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ProJob>>> getIncomingRequests() async {
    try {
      final requests = await remoteDataSource.getIncomingRequests();
      return Right(requests);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ProJob>>> getScheduledJobs() async {
    try {
      final jobs = await remoteDataSource.getScheduledJobs();
      return Right(jobs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> acceptJobRequest(String jobId) async {
    try {
      await remoteDataSource.acceptJobRequest(jobId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> declineJobRequest(String jobId) async {
    try {
      await remoteDataSource.declineJobRequest(jobId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateJobStatus(String jobId, String status) async {
    try {
      await remoteDataSource.updateJobStatus(jobId, status);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
