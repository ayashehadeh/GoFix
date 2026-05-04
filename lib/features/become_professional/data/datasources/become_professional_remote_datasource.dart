import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../models/category_service_model.dart';
import '../models/service_area_model.dart';
import '../models/service_pricing_model.dart';

abstract class BecomeProfessionalRemoteDataSource {
  // Lookups
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryServiceModel>> getServicesForCategory(int categoryId);
  Future<List<ServiceAreaModel>> getServiceAreas();

  // Application flow
  Future<void> createProfile({
    required int categoryId,
    required int experienceYears,
    required int cityId,
    required int serviceAreaId,
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
    required int cityId,
    required int serviceAreaId,
    required String bio,
  }) async {
    await dio.post(
      '/professionals/profile',
      data: {
        'categoryId': categoryId,
        'experienceYears': experienceYears,
        'cityId': cityId,
        'serviceAreaId': serviceAreaId,
        'bio': bio,
      },
    );
  }

  @override
  Future<void> setServices(List<ServicePricingModel> services) async {
    await dio.put(
      '/professionals/profile/services',
      data: {
        'services': services.map((s) => s.toJson()).toList(),
      },
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
      options: Options(contentType: 'multipart/form-data'),
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
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  @override
  Future<void> submitApplication() async {
    await dio.post('/professionals/profile/submit');
  }
}
