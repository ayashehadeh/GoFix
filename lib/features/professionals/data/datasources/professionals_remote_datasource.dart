import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gp/features/professionals/data/models/city_model.dart';
import 'package:gp/features/professionals/data/models/professional_model.dart';
import 'package:gp/features/professionals/data/models/review_model.dart';
import 'package:gp/features/professionals/data/models/service_area_model.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

abstract class ProfessionalsRemoteDataSource {
  Future<List<CityModel>> getCities();
  Future<List<ServiceAreaModel>> getServiceAreas({int? cityId});
  Future<List<ServiceAreaModel>> getServiceAreasByProfessional(String professionalId);
  Future<List<ProfessionalModel>> getProfessionalsByCategory(ServiceCategory category);
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

class ProfessionalsRemoteDataSourceImpl implements ProfessionalsRemoteDataSource {
  final Dio dio;

  ProfessionalsRemoteDataSourceImpl({required this.dio});

  // ── Helpers ───────────────────────────────────────────────────────────────

  // Get user's current location for distance calculation
  Future<Position?> _getUserLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  // Maps ServiceCategory enum to backend categoryId
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

  // ── Professionals ─────────────────────────────────────────────────────────

  @override
  Future<List<ProfessionalModel>> getProfessionalsByCategory(ServiceCategory category) async {
    final position = await _getUserLocation();

    final response = await dio.get(
      '/professionals',
      queryParameters: {
        'categoryId': _categoryId(category),
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lon': position.longitude,
      },
    );

    final data = response.data['data'] as List;
    return data.map((e) => ProfessionalModel.fromJson(e)).toList();
  }

  @override
  Future<ProfessionalModel> getProfessionalById(String id) async {
    final position = await _getUserLocation();

    final response = await dio.get(
      '/professionals/$id',
      queryParameters: {
        if (position != null) 'lat': position.latitude,
        if (position != null) 'lon': position.longitude,
      },
    );

    return ProfessionalModel.fromJson(response.data['data']);
  }

  @override
  Future<List<ProfessionalModel>> getFavorites() async {
    final response = await dio.get('/professionals/favorites');
    final data = response.data['data'] as List;
    return data.map((e) => ProfessionalModel.fromJson(e)).toList();
  }

  @override
  Future<void> toggleFavorite(String professionalId) async {
    await dio.post('/professionals/$professionalId/favorite');
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
  Future<List<ReviewModel>> getReviewsByProfessional(String professionalId) async {
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
      data: {
        'rating': rating,
        'comment': comment,
      },
    );

    return ReviewModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await dio.delete('/reviews/$reviewId');
  }

  @override
Future<List<CityModel>> getCities() async {
  final response = await dio.get('/cities');
  final data = response.data['data'] as List;
  return data.map((e) => CityModel.fromJson(e)).toList();
}

@override
Future<List<ServiceAreaModel>> getServiceAreas({int? cityId}) async {
  final response = await dio.get(
    '/professionals/service-areas',
    queryParameters: {
      if (cityId != null) 'cityId': cityId,
    },
  );
  final data = response.data['data'] as List;
  return data.map((e) => ServiceAreaModel.fromJson(e)).toList();
}

@override
Future<List<ServiceAreaModel>> getServiceAreasByProfessional(String professionalId) async {
  final response = await dio.get('/professionals/$professionalId/service-areas');
  final data = response.data['data'] as List;
  return data.map((e) => ServiceAreaModel.fromJson(e as Map<String, dynamic>)).toList();
}
}
