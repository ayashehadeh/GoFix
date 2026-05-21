import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/features/become_professional/domain/entities/city.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_service.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/service_area.dart';
import '../../domain/entities/service_pricing.dart';
import '../../domain/entities/working_hours_schedule.dart';
import '../../domain/repositories/become_professional_repository.dart';
import '../datasources/become_professional_remote_datasource.dart';
import '../models/service_pricing_model.dart';
import '../models/working_hours_model.dart';

class BecomeProfessionalRepositoryImpl implements BecomeProfessionalRepository {
  final BecomeProfessionalRemoteDataSource remoteDataSource;

  const BecomeProfessionalRepositoryImpl({required this.remoteDataSource});

  // ── Lookups ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Category>>> getCategories() {
    return _wrap(
        () async => (await remoteDataSource.getCategories()).cast<Category>());
  }

  @override
  Future<Either<Failure, List<CategoryService>>> getServicesForCategory(
    int categoryId,
  ) {
    return _wrap(() async =>
        (await remoteDataSource.getServicesForCategory(categoryId))
            .cast<CategoryService>());
  }

  @override
  Future<Either<Failure, List<ServiceArea>>> getServiceAreas() {
    return _wrap(() async =>
        (await remoteDataSource.getServiceAreas()).cast<ServiceArea>());
  }

  @override
  Future<Either<Failure, List<City>>> getCities() {
    return _wrap(() async => (await remoteDataSource.getCities()).cast<City>());
  }

  // ── Application flow ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> createProfile({
    required int categoryId,
    required int experienceYears,
    double? latitude,
    double? longitude,
    required String bio,
  }) {
    return _wrapUnit(() async => await remoteDataSource.createProfile(
          categoryId: categoryId,
          experienceYears: experienceYears,
          latitude: latitude,
          longitude: longitude,
          bio: bio,
        ));
  }

  @override
  Future<Either<Failure, Unit>> setServices(
    List<ServicePricing> services,
  ) {
    final models =
        services.map((s) => ServicePricingModel.fromEntity(s)).toList();
    return _wrapUnit(() async => await remoteDataSource.setServices(models));
  }

  @override
  Future<Either<Failure, Unit>> setServiceAreas(List<int> serviceAreaIds) {
    return _wrapUnit(
        () async => await remoteDataSource.setServiceAreas(serviceAreaIds));
  }

  @override
  Future<Either<Failure, Unit>> setWorkingHours(
      List<WorkingHoursSchedule> schedules) {
    final models = schedules
        .map((s) => WorkingHoursModel(
              dayLabel: s.dayLabel,
              openTime: s.openTime,
              closeTime: s.closeTime,
            ))
        .toList();
    return _wrapUnit(
        () async => await remoteDataSource.setWorkingHours(models));
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
    String? name,
    String? issuedBy,
    int? issuedYear,
  }) {
    return _wrapUnit(() async => await remoteDataSource.uploadDocument(
          filePath: filePath,
          documentType: documentType.apiValue,
          name: name,
          issuedBy: issuedBy,
          issuedYear: issuedYear,
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
      print(
          '_wrapUnit DioException: ${e.response?.statusCode} ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e, st) {
      print('_wrapUnit UNKNOWN ERROR: $e');
      print('_wrapUnit STACKTRACE: $st');
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return const ServerFailure('Your session expired. Please sign in again.');
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure('Network error');
    }
    final data = e.response?.data;
    final message =
        _extractBackendMessage(data) ?? e.response?.statusMessage ?? e.message;
    return ServerFailure(message?.trim().isNotEmpty == true
        ? message!.trim()
        : 'Something went wrong');
  }

  String? _extractBackendMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data.trim().isEmpty ? null : data;
    if (data is List) {
      for (final item in data) {
        final message = _extractBackendMessage(item);
        if (message != null && message.trim().isNotEmpty) return message;
      }
      return null;
    }
    if (data is Map) {
      final dynamic directMessage =
          data['message'] ?? data['error'] ?? data['detail'] ?? data['title'];
      if (directMessage is String && directMessage.trim().isNotEmpty) {
        return directMessage;
      }
      final dynamic errors = data['errors'] ?? data['validationErrors'];
      final nestedErrors = _extractBackendMessage(errors);
      if (nestedErrors != null) return nestedErrors;
      final dynamic innerData = data['data'] ?? data['result'];
      final nestedDataMessage = _extractBackendMessage(innerData);
      if (nestedDataMessage != null) return nestedDataMessage;
      for (final value in data.values) {
        final nested = _extractBackendMessage(value);
        if (nested != null && nested.trim().isNotEmpty) return nested;
      }
    }
    return null;
  }
}
