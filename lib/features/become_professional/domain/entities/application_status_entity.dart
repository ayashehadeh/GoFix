import 'package:equatable/equatable.dart';

enum ProfessionalStatus {
  draft,
  pendingReview,
  approved,
  rejected;

  static ProfessionalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return ProfessionalStatus.approved;
      case 'rejected':
        return ProfessionalStatus.rejected;
      case 'pendingreview':
      case 'pending_review':
      case 'pending':
        return ProfessionalStatus.pendingReview;
      default:
        return ProfessionalStatus.draft;
    }
  }
}

class ApplicationStatusEntity extends Equatable {
  final ProfessionalStatus status;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final bool hasProfile;
  final bool hasServices;
  final bool hasProfilePicture;
  final bool hasIdentityDocument;
  final bool hasCertification;
  final bool hasGoodConduct;

  const ApplicationStatusEntity({
    required this.status,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
    required this.hasProfile,
    required this.hasServices,
    required this.hasProfilePicture,
    required this.hasIdentityDocument,
    required this.hasCertification,
    required this.hasGoodConduct,
  });

  @override
  List<Object?> get props => [
        status,
        rejectionReason,
        submittedAt,
        reviewedAt,
        hasProfile,
        hasServices,
        hasProfilePicture,
        hasIdentityDocument,
        hasCertification,
        hasGoodConduct,
      ];
}
