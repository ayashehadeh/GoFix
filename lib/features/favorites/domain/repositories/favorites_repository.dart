import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/favorite_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(FavoriteEntity favorite);
  Future<Either<Failure, void>> removeFavorite(String professionalId);
  Future<Either<Failure, bool>> isFavorite(String professionalId);
}
