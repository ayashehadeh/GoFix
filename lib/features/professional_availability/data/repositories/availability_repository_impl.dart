import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_local_datasource.dart';
import '../models/availability_model.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityLocalDataSource localDataSource;

  AvailabilityRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AvailabilityEntity>> getAvailability() async {
    try {
      final availability = await localDataSource.getAvailability();
      return Right(availability);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveAvailability(
      AvailabilityEntity availability) async {
    try {
      final model = AvailabilityModel.fromEntity(availability);
      await localDataSource.saveAvailability(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
