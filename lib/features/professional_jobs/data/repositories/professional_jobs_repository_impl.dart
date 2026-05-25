import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/core/error/failures.dart';
import '../../domain/entities/pro_job.dart';
import '../../domain/repositories/professional_jobs_repository.dart';
import '../datasources/professional_jobs_datasource.dart';

class ProfessionalJobsRepositoryImpl implements ProfessionalJobsRepository {
  final ProfessionalJobsRemoteDataSource remoteDataSource;

  const ProfessionalJobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProJob>>> getUpcomingJobs() async {
    try {
      final jobs = await remoteDataSource.getUpcomingJobs();
      return Right(jobs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProJob>>> getPastJobs() async {
    try {
      final jobs = await remoteDataSource.getPastJobs();
      return Right(jobs);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Right([]);
      return Left(ServerFailure(e.message ?? 'Something went wrong'));
    } catch (e) {
      return Left(ServerFailure('Something went wrong'));
    }
  }

  @override
  Future<Either<Failure, ProJob>> updateJobStatus({
    required String jobId,
    required ProJobStatus newStatus,
  }) async {
    try {
      final job = await remoteDataSource.updateJobStatus(
        jobId: jobId,
        newStatus: newStatus,
      );
      return Right(job);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
