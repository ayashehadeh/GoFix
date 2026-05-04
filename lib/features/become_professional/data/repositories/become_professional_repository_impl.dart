import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/become_professional/domain/entities/professional_application.dart';
import 'package:gp/features/become_professional/domain/repositories/become_professional_repository.dart';
import '../datasources/become_professional_remote_datasource.dart';

class BecomeProfessionalRepositoryImpl implements BecomeProfessionalRepository {
  final BecomeProfessionalRemoteDataSource remoteDataSource;

  const BecomeProfessionalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createProfile({
    required int categoryId,
    required String bio,
    required int experienceYears,
  }) async {
    return _wrap(() => remoteDataSource.createProfile(
          categoryId: categoryId,
          bio: bio,
          experienceYears: experienceYears,
        ));
  }

  @override
  Future<Either<Failure, void>> setServiceArea(
      List<int> serviceAreaIds) async {
    return _wrap(() => remoteDataSource.setServiceArea(serviceAreaIds));
  }

  @override
  Future<Either<Failure, void>> setServices(
      List<ServicePricing> services) async {
    return _wrap(() => remoteDataSource.setServices(services));
  }

  @override
  Future<Either<Failure, void>> uploadProfilePicture(String filePath) async {
    return _wrap(() => remoteDataSource.uploadProfilePicture(filePath));
  }

  @override
  Future<Either<Failure, void>> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    return _wrap(() => remoteDataSource.uploadDocument(
          filePath: filePath,
          documentType: documentType,
        ));
  }

  @override
  Future<Either<Failure, void>> submitApplication() async {
    return _wrap(() => remoteDataSource.submitApplication());
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<Either<Failure, void>> _wrap(Future<void> Function() fn) async {
    try {
      await fn();
      return const Right(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      final msg = e.response?.data?['message'] as String? ??
          'Something went wrong';
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
