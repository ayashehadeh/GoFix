import 'package:equatable/equatable.dart';
import 'document_type.dart';
import 'service_pricing.dart';
import 'working_hours_schedule.dart';

/// In-memory snapshot of the application as the user works through the steps.
class ProfessionalApplication extends Equatable {
  // Step 1 – basic profile
  final int? categoryId;
  final String? categoryName;
  final int? experienceYears;
  final int? cityId;
  final String? cityName;
  final String bio;

  // Step 2 – services & pricing
  final List<ServicePricing> services;

  // Step 3a – service areas (multiple supported)
  final List<int> selectedServiceAreaIds;
  final List<String> selectedServiceAreaNames;

  // Step 3b – working hours
  final List<WorkingHoursSchedule> workingHours;

  // Step 3c – documents (local file paths until upload)
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
    this.bio = '',
    this.services = const [],
    this.selectedServiceAreaIds = const [],
    this.selectedServiceAreaNames = const [],
    this.workingHours = const [],
    this.profileImagePath,
    this.identityPath,
    this.certificationPath,
    this.goodConductPath,
  });

  bool get isStep1Valid =>
      categoryId != null &&
      categoryId! > 0 &&
      experienceYears != null &&
      bio.trim().isNotEmpty;

  bool get isStep2Valid => services.isNotEmpty;

  /// At least one service area must be selected.
  bool get isStep3aValid => selectedServiceAreaIds.isNotEmpty;

  /// At least one working day must be set.
  bool get isStep3bValid => workingHours.isNotEmpty;

  /// Profile picture and identity are required for final submission.
  bool get isStep4Valid =>
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
    String? bio,
    List<ServicePricing>? services,
    List<int>? selectedServiceAreaIds,
    List<String>? selectedServiceAreaNames,
    List<WorkingHoursSchedule>? workingHours,
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
      bio: bio ?? this.bio,
      services: services ?? this.services,
      selectedServiceAreaIds:
          selectedServiceAreaIds ?? this.selectedServiceAreaIds,
      selectedServiceAreaNames:
          selectedServiceAreaNames ?? this.selectedServiceAreaNames,
      workingHours: workingHours ?? this.workingHours,
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
        bio,
        services,
        selectedServiceAreaIds,
        selectedServiceAreaNames,
        workingHours,
        profileImagePath,
        identityPath,
        certificationPath,
        goodConductPath,
      ];
}
