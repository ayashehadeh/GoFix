import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/favorite_entity.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesList {
  final FavoritesRepository repository;
  GetFavoritesList(this.repository);
  Future<Either<Failure, List<FavoriteEntity>>> call() =>
      repository.getFavorites();
}

class AddFavorite {
  final FavoritesRepository repository;
  AddFavorite(this.repository);
  Future<Either<Failure, void>> call(FavoriteEntity favorite) =>
      repository.addFavorite(favorite);
}

class RemoveFavorite {
  final FavoritesRepository repository;
  RemoveFavorite(this.repository);
  Future<Either<Failure, void>> call(String professionalId) =>
      repository.removeFavorite(professionalId);
}

class IsFavorite {
  final FavoritesRepository repository;
  IsFavorite(this.repository);
  Future<Either<Failure, bool>> call(String professionalId) =>
      repository.isFavorite(professionalId);
}
