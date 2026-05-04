import 'package:equatable/equatable.dart';
import 'document_type.dart';
import 'service_pricing.dart';

/// In-memory snapshot of the application as the user works through the steps.
/// This is held by the BLoC and used to drive validation + submission.
class ProfessionalApplication extends Equatable {
  // Step 1
  final int? categoryId;
  final String? categoryName;
  final int? experienceYears;
  final int? cityId;
  final String? cityName;
  final int? serviceAreaId;
  final String? serviceAreaName;
  final String bio;

  // Step 2
  final List<ServicePricing> services;

  // Step 3 — local file paths (only used until upload succeeds)
  final String? profileImagePath;
  final String? identityPath;
  final String? certificationPath;
  final String? goodConductPath;

  const ProfessionalApplication({
    this.categoryId,
    this.categoryName,
    this.experienceYears,
    this.cityId,
    this.cityName,
    this.serviceAreaId,
    this.serviceAreaName,
    this.bio = '',
    this.services = const [],
    this.profileImagePath,
    this.identityPath,
    this.certificationPath,
    this.goodConductPath,
  });

  bool get isStep1Valid =>
      categoryId != null &&
      categoryId! > 0 &&
      experienceYears != null &&
      cityId != null &&
      cityId! > 0 &&
      serviceAreaId != null &&
      serviceAreaId! > 0 &&
      bio.trim().isNotEmpty;

  bool get isStep2Valid => services.isNotEmpty;

  /// Profile picture and identity are required, certification & good conduct optional.
  bool get isStep3Valid =>
      profileImagePath != null && identityPath != null;

  String? pathFor(DocumentType type) {
    switch (type) {
      case DocumentType.identity:
        return identityPath;
      case DocumentType.certification:
        return certificationPath;
      case DocumentType.goodConduct:
        return goodConductPath;
    }
  }

  ProfessionalApplication copyWith({
    int? categoryId,
    String? categoryName,
    int? experienceYears,
    int? cityId,
    String? cityName,
    int? serviceAreaId,
    String? serviceAreaName,
    String? bio,
    List<ServicePricing>? services,
    String? profileImagePath,
    String? identityPath,
    String? certificationPath,
    String? goodConductPath,
  }) {
    return ProfessionalApplication(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      experienceYears: experienceYears ?? this.experienceYears,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      serviceAreaId: serviceAreaId ?? this.serviceAreaId,
      serviceAreaName: serviceAreaName ?? this.serviceAreaName,
      bio: bio ?? this.bio,
      services: services ?? this.services,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      identityPath: identityPath ?? this.identityPath,
      certificationPath: certificationPath ?? this.certificationPath,
      goodConductPath: goodConductPath ?? this.goodConductPath,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        experienceYears,
        cityId,
        cityName,
        serviceAreaId,
        serviceAreaName,
        bio,
        services,
        profileImagePath,
        identityPath,
        certificationPath,
        goodConductPath,
      ];
}
