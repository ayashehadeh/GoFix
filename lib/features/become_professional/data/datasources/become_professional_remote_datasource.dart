import 'package:dio/dio.dart';
import '../models/professional_application_model.dart';

abstract class BecomeProfessionalRemoteDataSource {
  Future<void> submitApplication(ProfessionalApplicationModel application);
}

class BecomeProfessionalRemoteDataSourceImpl
    implements BecomeProfessionalRemoteDataSource {
  final Dio dio;

  const BecomeProfessionalRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> submitApplication(
    ProfessionalApplicationModel application,
  ) async {
    final formData = FormData.fromMap({
      'serviceCategory': application.serviceCategory,
      'experienceLevel': application.experienceLevel,
      'workDescription': application.workDescription,
      'services': application.toJson()['services'],
      if (application.profileImagePath != null)
        'profileImage': await MultipartFile.fromFile(
          application.profileImagePath!,
          filename: 'profile.jpg',
        ),
      if (application.idImagePath != null)
        'idImage': await MultipartFile.fromFile(
          application.idImagePath!,
          filename: 'id.jpg',
        ),
      if (application.certificationImagePath != null)
        'certificationImage': await MultipartFile.fromFile(
          application.certificationImagePath!,
          filename: 'certification.jpg',
        ),
      if (application.conductImagePath != null)
        'conductImage': await MultipartFile.fromFile(
          application.conductImagePath!,
          filename: 'conduct.jpg',
        ),
    });

    await dio.post(
      '/professionals/apply',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }
}
