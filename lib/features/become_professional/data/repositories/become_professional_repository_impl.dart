import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_service.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/service_area.dart';
import '../../domain/entities/service_pricing.dart';
import '../../domain/repositories/become_professional_repository.dart';
import '../datasources/become_professional_remote_datasource.dart';
import '../models/service_pricing_model.dart';

class BecomeProfessionalRepositoryImpl
    implements BecomeProfessionalRepository {
  final BecomeProfessionalRemoteDataSource remoteDataSource;

  const BecomeProfessionalRepositoryImpl({required this.remoteDataSource});

  // ── Lookups ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Category>>> getCategories() {
    return _wrap(() async => (await remoteDataSource.getCategories()).cast<Category>());
  }

  @override
  Future<Either<Failure, List<CategoryService>>> getServicesForCategory(
    int categoryId,
  ) {
    return _wrap(
      () async => (await remoteDataSource.getServicesForCategory(categoryId)).cast<CategoryService>(),
    );
  }

  @override
  Future<Either<Failure, List<ServiceArea>>> getServiceAreas() {
    return _wrap(() async => (await remoteDataSource.getServiceAreas()).cast<ServiceArea>());
  }

  // ── Application flow ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> createProfile({
    required int categoryId,
    required int experienceYears,
    required int cityId,
    required int serviceAreaId,
    required String bio,
  }) {
    return _wrapUnit(() async => await remoteDataSource.createProfile(
          categoryId: categoryId,
          experienceYears: experienceYears,
          cityId: cityId,
          serviceAreaId: serviceAreaId,
          bio: bio,
        ));
  }

  @override
  Future<Either<Failure, Unit>> setServices(
    List<ServicePricing> services,
  ) {
    final models = services
        .map((s) => ServicePricingModel.fromEntity(s))
        .toList();
    return _wrapUnit(() async => await remoteDataSource.setServices(models));
  }

  @override
  Future<Either<Failure, Unit>> uploadProfilePicture(String filePath) {
    return _wrapUnit(
      () async => await remoteDataSource.uploadProfilePicture(filePath),
    );
  }

  @override
  Future<Either<Failure, Unit>> uploadDocument({
    required String filePath,
    required DocumentType documentType,
  }) {
    return _wrapUnit(() async => await remoteDataSource.uploadDocument(
          filePath: filePath,
          documentType: documentType.apiValue,
        ));
  }

  @override
  Future<Either<Failure, Unit>> submitApplication() {
    return _wrapUnit(
      () async => await remoteDataSource.submitApplication(),
    );
  }

  // ── Error handling ────────────────────────────────────────────────────────

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      final result = await fn();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _wrapUnit(Future<void> Function() fn) async {
    try {
      await fn();
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure();
    }
    final data = e.response?.data;
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? data['error'] as String?;
    }
    return ServerFailure(message ?? 'Something went wrong');
  }
}
