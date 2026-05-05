import 'package:dio/dio.dart';
import 'package:gp/core/storage/token_storage.dart';
import '../models/category_model.dart';
import '../models/category_service_model.dart';
import '../models/service_area_model.dart';
import '../models/service_pricing_model.dart';
import '../models/city_model.dart';

abstract class BecomeProfessionalRemoteDataSource {
  // Lookups
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryServiceModel>> getServicesForCategory(int categoryId);
  Future<List<ServiceAreaModel>> getServiceAreas();
  Future<List<CityModel>> getCities();

  // Application flow
  Future<void> createProfile({
    required int categoryId,
    required int experienceYears,
    int? serviceAreaId,
    double? latitude,
    double? longitude,
    required String bio,
  });

  Future<void> setServices(List<ServicePricingModel> services);

  Future<void> uploadProfilePicture(String filePath);

  Future<void> uploadDocument({
    required String filePath,
    required String documentType,
  });

  Future<void> submitApplication();
}

class BecomeProfessionalRemoteDataSourceImpl
    implements BecomeProfessionalRemoteDataSource {
  final Dio dio;

  const BecomeProfessionalRemoteDataSourceImpl({required this.dio});

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Pulls the list field out of common response envelopes:
  /// `{ data: [...] }`, `{ data: { items: [...] } }`, or a bare list.
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final items = data['items'] ?? data['results'] ?? data['list'];
        if (items is List) return items;
      }
    }
    return const [];
  }

  // ── Lookups ───────────────────────────────────────────────────────────────

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get('/categories');
    final list = _extractList(response.data);
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategoryServiceModel>> getServicesForCategory(
    int categoryId,
  ) async {
    final response = await dio.get(
      '/professionals/services',
      queryParameters: {'categoryId': categoryId},
    );
    final list = _extractList(response.data);
    return list
        .map((e) => CategoryServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ServiceAreaModel>> getServiceAreas() async {
    final response = await dio.get('/professionals/service-areas');
    final list = _extractList(response.data);
    return list
        .map((e) => ServiceAreaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Application flow ──────────────────────────────────────────────────────

  @override
  Future<void> createProfile({
    required int categoryId,
    required int experienceYears,
    int? serviceAreaId,
    double? latitude,
    double? longitude,
    required String bio,
  }) async {
    final payload = {
      'categoryId': categoryId,
      'experienceYears': experienceYears,
      if (serviceAreaId != null) 'serviceAreaId': serviceAreaId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'bio': bio,
    };

    try {
      await dio.post(
        '/professionals/profile',
        data: payload,
        options: Options(headers: await _authHeaders()),
      );
    } on DioException catch (e) {
      // If a profile already exists (or backend only allows update), retry as PUT.
      final code = e.response?.statusCode;
      if (code == 405 || code == 409 || code == 422) {
        await dio.put(
          '/professionals/profile',
          data: payload,
          options: Options(headers: await _authHeaders()),
        );
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> setServices(List<ServicePricingModel> services) async {
    await dio.put(
      '/professionals/profile/services',
      data: {
        'services': services.map((s) => s.toJson()).toList(),
      },
      options: Options(headers: await _authHeaders()),
    );
  }

  @override
  Future<void> uploadProfilePicture(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    await dio.post(
      '/auth/profile-picture',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: await _authHeaders(),
      ),
    );
  }

  @override
  Future<void> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'documentType': documentType,
    });
    await dio.post(
      '/professionals/profile/documents',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: await _authHeaders(),
      ),
    );
  }

  @override
  Future<void> submitApplication() async {
    await dio.post(
      '/professionals/profile/submit',
      options: Options(headers: await _authHeaders()),
    );
  }

  @override
Future<List<CityModel>> getCities() async {
  final response = await dio.get('/professionals/cities');
  final list = _extractList(response.data);
  return list
      .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
}
