import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/professional_application.dart';
import '../../domain/repositories/become_professional_repository.dart';
import '../datasources/become_professional_remote_datasource.dart';
import '../models/professional_application_model.dart';

class BecomeProfessionalRepositoryImpl implements BecomeProfessionalRepository {
  final BecomeProfessionalRemoteDataSource remoteDataSource;

  const BecomeProfessionalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> submitApplication(
    ProfessionalApplication application,
  ) async {
    try {
      final model = ProfessionalApplicationModel.fromEntity(application);
      await remoteDataSource.submitApplication(model);
      return const Right(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      return Left(
        ServerFailure(
          e.response?.data?['message'] as String? ?? 'Something went wrong',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
