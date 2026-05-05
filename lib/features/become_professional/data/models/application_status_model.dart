import '../../domain/entities/application_status_entity.dart';

class ApplicationStatusModel extends ApplicationStatusEntity {
  const ApplicationStatusModel({
    required super.status,
    super.rejectionReason,
    super.submittedAt,
    super.reviewedAt,
    required super.hasProfile,
    required super.hasServices,
    required super.hasProfilePicture,
    required super.hasIdentityDocument,
    required super.hasCertification,
    required super.hasGoodConduct,
  });

  factory ApplicationStatusModel.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusModel(
      status: ProfessionalStatus.fromString(
        json['status'] as String? ?? 'draft',
      ),
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt'] as String) : null,
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'] as String) : null,
      hasProfile: json['hasProfile'] as bool? ?? false,
      hasServices: json['hasServices'] as bool? ?? false,
      hasProfilePicture: json['hasProfilePicture'] as bool? ?? false,
      hasIdentityDocument: json['hasIdentityDocument'] as bool? ?? false,
      hasCertification: json['hasCertification'] as bool? ?? false,
      hasGoodConduct: json['hasGoodConduct'] as bool? ?? false,
    );
  }
}
