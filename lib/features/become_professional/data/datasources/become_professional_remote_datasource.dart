import 'package:dio/dio.dart';
import 'package:gp/core/storage/token_storage.dart';
import '../models/category_model.dart';
import '../models/category_service_model.dart';
import '../models/service_area_model.dart';
import '../models/service_pricing_model.dart';
import '../models/city_model.dart';
import '../models/working_hours_model.dart';

abstract class BecomeProfessionalRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryServiceModel>> getServicesForCategory(int categoryId);
  Future<List<ServiceAreaModel>> getServiceAreas();
  Future<List<CityModel>> getCities();

  Future<void> createProfile({
    required int categoryId,
    required int experienceYears,
    double? latitude,
    double? longitude,
    required String bio,
  });

  Future<void> setServices(List<ServicePricingModel> services);
  Future<void> setServiceAreas(List<int> serviceAreaIds);
  Future<void> setWorkingHours(List<WorkingHoursModel> schedules);
  Future<void> uploadProfilePicture(String filePath);

  Future<void> uploadDocument({
    required String filePath,
    required String documentType,
    String? name,
    String? issuedBy,
    int? issuedYear,
  });

  Future<void> submitApplication();
}

class BecomeProfessionalRemoteDataSourceImpl implements BecomeProfessionalRemoteDataSource {
  final Dio dio;

  const BecomeProfessionalRemoteDataSourceImpl({required this.dio});

  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

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

  /// Returns a MIME type string for a given file extension.
  String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'heic':
        return 'image/heic';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get('/categories');
    final list = _extractList(response.data);
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CategoryServiceModel>> getServicesForCategory(int categoryId) async {
    final response = await dio.get(
      '/professionals/services',
      queryParameters: {'categoryId': categoryId},
    );
    final list = _extractList(response.data);
    return list.map((e) => CategoryServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ServiceAreaModel>> getServiceAreas() async {
    final response = await dio.get('/professionals/service-areas');
    final list = _extractList(response.data);
    return list.map((e) => ServiceAreaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<CityModel>> getCities() async {
    final response = await dio.get('/professionals/cities');
    final list = _extractList(response.data);
    return list.map((e) => CityModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createProfile({
    required int categoryId,
    required int experienceYears,
    double? latitude,
    double? longitude,
    required String bio,
  }) async {
    final payload = {
      'categoryId': categoryId,
      'experienceYears': experienceYears,
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
      data: {'services': services.map((s) => s.toJson()).toList()},
      options: Options(headers: await _authHeaders()),
    );
  }

  @override
  Future<void> setServiceAreas(List<int> serviceAreaIds) async {
    await dio.put(
      '/professionals/profile/service-areas',
      data: {'serviceAreaIds': serviceAreaIds},
      options: Options(headers: await _authHeaders()),
    );
  }

  @override
  Future<void> setWorkingHours(List<WorkingHoursModel> schedules) async {
    await dio.put(
      '/professionals/profile/working-hours',
      data: {'schedules': schedules.map((s) => s.toJson()).toList()},
      options: Options(headers: await _authHeaders()),
    );
  }

  @override
  Future<void> uploadProfilePicture(String filePath) async {
    final fileName = filePath.split('/').last;
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';

    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: DioMediaType.parse(_mimeType(ext)),
      ),
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
    String? name,
    String? issuedBy,
    int? issuedYear,
  }) async {
    final fileName = filePath.split('/').last;
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';

    print('UPLOAD DOC: type=$documentType file=$filePath filename=$fileName mime=${_mimeType(ext)}');

    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: DioMediaType.parse(_mimeType(ext)),
      ),
      'DocumentType': documentType,
      if (name != null) 'Name': name,
      if (issuedBy != null) 'IssuedBy': issuedBy,
      if (issuedYear != null) 'IssuedYear': issuedYear,
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
}
