import '../../domain/entities/professional_application.dart';

class ProfessionalApplicationModel extends ProfessionalApplication {
  const ProfessionalApplicationModel({
    required super.serviceCategory,
    required super.experienceLevel,
    required super.workDescription,
    required super.services,
    super.profileImagePath,
    super.idImagePath,
    super.certificationImagePath,
    super.conductImagePath,
  });

  factory ProfessionalApplicationModel.fromEntity(
    ProfessionalApplication entity,
  ) {
    return ProfessionalApplicationModel(
      serviceCategory: entity.serviceCategory,
      experienceLevel: entity.experienceLevel,
      workDescription: entity.workDescription,
      services: entity.services,
      profileImagePath: entity.profileImagePath,
      idImagePath: entity.idImagePath,
      certificationImagePath: entity.certificationImagePath,
      conductImagePath: entity.conductImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceCategory': serviceCategory,
        'experienceLevel': experienceLevel,
        'workDescription': workDescription,
        'services': services
            .map((s) => {
                  'serviceName': s.serviceName,
                  'price': s.price,
                })
            .toList(),
        // Image files are sent as multipart — paths are handled separately
      };
}
