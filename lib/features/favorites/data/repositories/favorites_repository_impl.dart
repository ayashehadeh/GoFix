import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../models/favorite_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource dataSource;
  FavoritesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites() async {
    try {
      final result = await dataSource.getFavorites();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(FavoriteEntity favorite) async {
    try {
      await dataSource.addFavorite(
        FavoriteModel(
          id: favorite.id,
          name: favorite.name,
          role: favorite.role,
          yearsExperience: favorite.yearsExperience,
          imageUrl: favorite.imageUrl,
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String professionalId) async {
    try {
      await dataSource.removeFavorite(professionalId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String professionalId) async {
    try {
      final result = await dataSource.isFavorite(professionalId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
