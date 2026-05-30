import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gp/core/services/cache_service.dart';
import 'package:gp/features/professionals/data/models/city_model.dart';
import 'package:gp/features/professionals/data/models/professional_model.dart';
import 'package:gp/features/professionals/data/models/review_model.dart';
import 'package:gp/features/professionals/data/models/service_area_model.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

abstract class ProfessionalsRemoteDataSource {
  Future<List<CityModel>> getCities();
  Future<ProfessionalModel> getMyProfile();
  Future<List<ServiceAreaModel>> getServiceAreas({int? cityId});
  Future<List<ServiceAreaModel>> getServiceAreasByProfessional(
      String professionalId);
  Future<List<ProfessionalModel>> getProfessionalsByCategory(
      ServiceCategory category);
  Future<ProfessionalModel> getProfessionalById(String id);
  Future<List<ProfessionalModel>> getFavorites();
  Future<void> toggleFavorite(String professionalId);
  Future<List<ProfessionalModel>> searchProfessionals(String query);
  Future<List<ProfessionalModel>> filterProfessionals({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  });
  Future<List<ReviewModel>> getReviewsByProfessional(String professionalId);
  Future<ReviewModel> addReview({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  });
  Future<ReviewModel> editReview({
    required String reviewId,
    required double rating,
    required String comment,
  });
  Future<void> deleteReview(String reviewId);
}

class ProfessionalsRemoteDataSourceImpl
    implements ProfessionalsRemoteDataSource {
  final Dio dio;
  final CacheService cache;

  ProfessionalsRemoteDataSourceImpl({required this.dio, required this.cache});

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Position?> _getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  int _categoryId(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.plumbing:
        return 1;
      case ServiceCategory.electricalWork:
        return 2;
      case ServiceCategory.acRepair:
        return 3;
      case ServiceCategory.carpentry:
        return 4;
      case ServiceCategory.painting:
        return 5;
      case ServiceCategory.cleaning:
        return 6;
      case ServiceCategory.movingServices:
        return 7;
      case ServiceCategory.applianceRepair:
        return 8;
    }
  }

  // ── City & area lookups ───────────────────────────────────────────────────

  @override
  Future<List<CityModel>> getCities() async {
    const key = 'cities';
    final cached = cache.get<List<CityModel>>(key);
    if (cached != null) return cached;

    final response = await dio.get('/professionals/cities');
    final data = response.data['data'] as List;
    final result = data.map((e) => CityModel.fromJson(e)).toList();
    cache.set(key, result);
    return result;
  }

  @override
  Future<ProfessionalModel> getMyProfile() async {
    final response = await dio.get('/professionals/profile/me');
    return ProfessionalModel.fromJson(response.data['data']);
  }

  @override
  Future<List<ServiceAreaModel>> getServiceAreas({int? cityId}) async {
    final key = 'service-areas:${cityId ?? "all"}';
    final cached = cache.get<List<ServiceAreaModel>>(key);
    if (cached != null) return cached;

    final response = await dio.get(
      '/professionals/service-areas',
      queryParameters: {
        if (cityId != null) 'cityId': cityId,
      },
    );
    final data = response.data['data'] as List;
    final result = data.map((e) => ServiceAreaModel.fromJson(e)).toList();
    cache.set(key, result);
    return result;
  }

  @override
  Future<List<ServiceAreaModel>> getServiceAreasByProfessional(
      String professionalId) async {
    final response =
        await dio.get('/professionals/$professionalId/service-areas');
    final data = response.data['data'] as List;
    return data
        .map((e) =>
            ServiceAreaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Professionals ─────────────────────────────────────────────────────────

  @override
  Future<List<ProfessionalModel>> getProfessionalsByCategory(
      ServiceCategory category) async {
    final catId = _categoryId(category);
    final position = await _getUserLocation();
    final key = 'professionals:cat:$catId';
    final cached = cache.get<List<ProfessionalModel>>(key);
    if (cached != null) return cached;

    final response = await dio.get(
      '/professionals',
      queryParameters: {
        'categoryId': catId,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lon': position.longitude,
      },
    );
    final data = response.data['data'] as List;
    final result = data.map((e) => ProfessionalModel.fromJson(e)).toList();
    cache.set(key, result, ttl: const Duration(minutes: 5));
    return result;
  }

  @override
  Future<ProfessionalModel> getProfessionalById(String id) async {
    final key = 'professional:$id';
    final cached = cache.get<ProfessionalModel>(key);
    if (cached != null) return cached;

    final position = await _getUserLocation();
    final response = await dio.get(
      '/professionals/$id',
      queryParameters: {
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lon': position.longitude,
      },
    );
    final result = ProfessionalModel.fromJson(response.data['data']);
    cache.set(key, result, ttl: const Duration(minutes: 5));
    return result;
  }

  @override
  Future<List<ProfessionalModel>> getFavorites() async {
    const key = 'favorites';
    final cached = cache.get<List<ProfessionalModel>>(key);
    if (cached != null) return cached;

    final response = await dio.get('/professionals/favorites');
    final data = response.data['data'] as List;
    final result = data.map((e) => ProfessionalModel.fromJson(e)).toList();
    cache.set(key, result, ttl: const Duration(minutes: 2));
    return result;
  }

  @override
  Future<void> toggleFavorite(String professionalId) async {
    await dio.post('/professionals/$professionalId/favorite');
    // Invalidate so favorites list and profile IsFavorite flag are re-fetched
    cache.invalidate('favorites');
    cache.invalidate('professional:$professionalId');
  }

  @override
  Future<List<ProfessionalModel>> searchProfessionals(String query) async {
    final position = await _getUserLocation();
    final response = await dio.get(
      '/professionals/search',
      queryParameters: {
        'q': query,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lon': position.longitude,
      },
    );
    final data = response.data['data'] as List;
    return data.map((e) => ProfessionalModel.fromJson(e)).toList();
  }

  @override
  Future<List<ProfessionalModel>> filterProfessionals({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  }) async {
    final position = await _getUserLocation();
    final response = await dio.get(
      '/professionals/filter',
      queryParameters: {
        'categoryId': _categoryId(category),
        if (minExperienceYears != null) 'minExp': minExperienceYears,
        if (maxDistanceKm != null) 'maxDistance': maxDistanceKm,
        if (minRating != null) 'minRating': minRating,
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lon': position.longitude,
      },
    );
    final data = response.data['data'] as List;
    return data.map((e) => ProfessionalModel.fromJson(e)).toList();
  }

  // ── Reviews ───────────────────────────────────────────────────────────────

  @override
  Future<List<ReviewModel>> getReviewsByProfessional(
      String professionalId) async {
    final response = await dio.get(
      '/reviews',
      queryParameters: {'professionalId': professionalId},
    );
    final data = response.data['data'] as List;
    return data.map((e) => ReviewModel.fromJson(e)).toList();
  }

  @override
  Future<ReviewModel> addReview({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    final response = await dio.post(
      '/reviews',
      data: {
        'professionalId': professionalId,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      },
    );
    // Invalidate cached profile so updated rating is reflected
    cache.invalidate('professional:$professionalId');
    return ReviewModel.fromJson(response.data['data']);
  }

  @override
  Future<ReviewModel> editReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    final response = await dio.put(
      '/reviews/$reviewId',
      data: {'rating': rating, 'comment': comment},
    );
    return ReviewModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await dio.delete('/reviews/$reviewId');
  }
}
