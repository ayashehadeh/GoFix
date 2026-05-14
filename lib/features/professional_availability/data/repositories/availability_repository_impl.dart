import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_local_datasource.dart';
import '../datasources/availability_remote_datasource.dart';
import '../models/availability_model.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityRemoteDataSource remoteDataSource;
  final AvailabilityLocalDataSource localDataSource;

  AvailabilityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // 1. Try remote first
  // 2. On success, cache the result locally
  // 3. On network failure, fall back to local cache
  // 4. If both fail, return ServerFailure
  @override
  Future<Either<Failure, AvailabilityEntity>> getAvailability() async {
    try {
      final model = await remoteDataSource.getWorkingHours();
      await localDataSource.cacheAvailability(model);
      return Right(model);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Network issue — try cache
        try {
          final cached = await localDataSource.getCachedAvailability();
          if (cached != null) return Right(cached);
        } catch (_) {}
      }
      return Left(ServerFailure(
        e.response?.data?['message'] as String? ?? 'Failed to load availability',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Sends schedules to API, then updates local cache on success
  @override
  Future<Either<Failure, void>> saveWorkingHours(
      List<DaySchedule> schedules) async {
    try {
      // Build a model with the current isAvailable from cache (we're only updating schedules)
      final cached = await localDataSource.getCachedAvailability();
      final model = AvailabilityModel(
        isAvailable: cached?.isAvailable ?? true,
        schedules: schedules,
      );
      await remoteDataSource.setWorkingHours(model);
      await localDataSource.cacheAvailability(model);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message'] as String? ?? 'Failed to save working hours',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Toggles availability on API, then updates local cache on success
  @override
  Future<Either<Failure, void>> toggleAvailability(
      {required bool isAvailable}) async {
    try {
      await remoteDataSource.toggleAvailability(isAvailable: isAvailable);
      // Update cached isAvailable without touching schedules
      final cached = await localDataSource.getCachedAvailability();
      if (cached != null) {
        await localDataSource.cacheAvailability(
          AvailabilityModel(
            isAvailable: isAvailable,
            schedules: cached.schedules,
          ),
        );
      }
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.data?['message'] as String? ?? 'Failed to toggle availability',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}