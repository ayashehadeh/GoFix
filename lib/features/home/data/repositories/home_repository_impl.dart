import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/features/home/data/data_sources/data_remote_datasource.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/home_repository.dart';


class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      return Left(ServerFailure(
        e.response?.data?['message'] as String? ?? 'Failed to load categories',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}