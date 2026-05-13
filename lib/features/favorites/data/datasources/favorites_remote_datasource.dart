import 'package:dio/dio.dart';
import '../models/favorite_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites();
  Future<void> addFavorite(FavoriteModel favorite);
  Future<void> removeFavorite(String professionalId);
  Future<bool> isFavorite(String professionalId);
}

/// Real implementation — swap to this when the backend is ready.
class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final Dio dio;
  FavoritesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    final response = await dio.get('/professionals/favorites');
    final data = response.data['data'] as List;
    return data.map((e) => FavoriteModel.fromJson(e)).toList();
  }

  @override
  Future<void> addFavorite(FavoriteModel favorite) async {
    await dio.post('/professionals/${favorite.id}/favorite');
  }

  @override
  Future<void> removeFavorite(String professionalId) async {
    await dio.post('/professionals/$professionalId/favorite');
  }

  @override
  Future<bool> isFavorite(String professionalId) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.id == professionalId);
  }
}

/// Singleton in-memory mock so professionals & favorites screens share data.
/// Toggle a heart in the professionals screen → it immediately appears in
/// favorites.
class MockFavoritesDataSource implements FavoritesRemoteDataSource {
  static final MockFavoritesDataSource _instance = MockFavoritesDataSource._internal();
  factory MockFavoritesDataSource() => _instance;
  MockFavoritesDataSource._internal();

  final List<FavoriteModel> _favorites = [
    const FavoriteModel(id: '1', name: 'Mohammed Hassan', role: 'Plumber', yearsExperience: 10),
    const FavoriteModel(id: '2', name: 'Ali Emad', role: 'Ac repairer', yearsExperience: 10),
    const FavoriteModel(id: '3', name: 'Abdullah Zaid', role: 'Carpenter', yearsExperience: 5),
    const FavoriteModel(id: '4', name: 'Sara Mohammad', role: 'Cleaner', yearsExperience: 9),
    const FavoriteModel(id: '5', name: "Ra'ed Mahmood", role: 'Electrician', yearsExperience: 3),
  ];

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_favorites);
  }

  @override
  Future<void> addFavorite(FavoriteModel favorite) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_favorites.any((f) => f.id == favorite.id)) {
      _favorites.add(favorite);
    }
  }

  @override
  Future<void> removeFavorite(String professionalId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.removeWhere((f) => f.id == professionalId);
  }

  @override
  Future<bool> isFavorite(String professionalId) async {
    return _favorites.any((f) => f.id == professionalId);
  }
}
