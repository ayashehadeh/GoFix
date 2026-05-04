import 'package:dio/dio.dart';
import 'package:gp/features/become_professional/domain/entities/professional_application.dart';

abstract class BecomeProfessionalRemoteDataSource {
  Future<void> createProfile({
    required int categoryId,
    required String bio,
    required int experienceYears,
  });

  Future<void> setServiceArea(List<int> serviceAreaIds);

  Future<void> setServices(List<ServicePricing> services);

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

  BecomeProfessionalRemoteDataSourceImpl({required this.dio});

  // POST /api/professionals/profile
  @override
  Future<void> createProfile({
    required int categoryId,
    required String bio,
    required int experienceYears,
  }) async {
    await dio.post('/professionals/profile', data: {
      'categoryId': categoryId,
      'bio': bio,
      'experienceYears': experienceYears,
    });
  }

  // PUT /api/professionals/profile/service-areas
  @override
  Future<void> setServiceArea(List<int> serviceAreaIds) async {
    await dio.put('/professionals/profile/service-areas', data: {
      'serviceAreaIds': serviceAreaIds,
    });
  }

  // PUT /api/professionals/profile/services
  @override
  Future<void> setServices(List<ServicePricing> services) async {
    await dio.put('/professionals/profile/services', data: {
      'services': services
          .map((s) => {
                'serviceId': s.serviceId,
                'minPrice': s.minPrice,
                if (s.maxPrice != null) 'maxPrice': s.maxPrice,
              })
          .toList(),
    });
  }

  // POST /api/professionals/profile/picture  (multipart)
  @override
  Future<void> uploadProfilePicture(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    await dio.post(
      '/professionals/profile/picture',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  // POST /api/professionals/profile/documents  (multipart)
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

  // POST /api/professionals/profile/submit
  @override
  Future<void> submitApplication() async {
    await dio.post('/professionals/profile/submit');
  }
}
