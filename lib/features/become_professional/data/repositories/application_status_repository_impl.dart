import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/application_status_entity.dart';
import '../../domain/repositories/application_status_repository.dart';
import '../datasources/application_status_remote_datasource.dart';

class ApplicationStatusRepositoryImpl implements ApplicationStatusRepository {
  final ApplicationStatusRemoteDataSource remoteDataSource;
  const ApplicationStatusRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ApplicationStatusEntity>> getApplicationStatus() async {
    try {
      final result = await remoteDataSource.getApplicationStatus();
      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      final msg = e.response?.data?['message'] as String? ?? 'Something went wrong';
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
