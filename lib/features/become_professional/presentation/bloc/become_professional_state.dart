import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/city.dart';
import 'package:gp/features/professionals/domain/entities/service_area.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import '../../domain/entities/professional_application.dart';
import 'become_professional_event.dart';

abstract class BecomeProfessionalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BecomeProfessionalInitial extends BecomeProfessionalState {}

// ── Main form state (persists across all 3 steps) ─────────────────────────────

class BecomeProfessionalFormState extends BecomeProfessionalState {
  final String serviceCategory;
  final int categoryId;
  final String experienceLevel;
  final String workDescription;
  final int cityId;
  final int serviceAreaId;
  final List<ServicePricing> services;
  final String? profileImagePath;
  final String? idImagePath;
  final String? certificationImagePath;
  final String? conductImagePath;

  BecomeProfessionalFormState({
    this.serviceCategory = '',
    this.categoryId = 0,
    this.experienceLevel = '',
    this.workDescription = '',
    this.cityId = 0,
    this.serviceAreaId = 0,
    this.services = const [],
    this.profileImagePath,
    this.idImagePath,
    this.certificationImagePath,
    this.conductImagePath,
  });

  String? pathFor(DocumentType type) {
    switch (type) {
      case DocumentType.profile:
        return profileImagePath;
      case DocumentType.id:
        return idImagePath;
      case DocumentType.certification:
        return certificationImagePath;
      case DocumentType.conduct:
        return conductImagePath;
    }
  }

  BecomeProfessionalFormState copyWith({
    String? serviceCategory,
    int? categoryId,
    String? experienceLevel,
    String? workDescription,
    int? cityId,
    int? serviceAreaId,
    List<ServicePricing>? services,
    String? profileImagePath,
    String? idImagePath,
    String? certificationImagePath,
    String? conductImagePath,
  }) {
    return BecomeProfessionalFormState(
      serviceCategory: serviceCategory ?? this.serviceCategory,
      categoryId: categoryId ?? this.categoryId,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      workDescription: workDescription ?? this.workDescription,
      cityId: cityId ?? this.cityId,
      serviceAreaId: serviceAreaId ?? this.serviceAreaId,
      services: services ?? this.services,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      idImagePath: idImagePath ?? this.idImagePath,
      certificationImagePath:
          certificationImagePath ?? this.certificationImagePath,
      conductImagePath: conductImagePath ?? this.conductImagePath,
    );
  }

  ProfessionalApplication toEntity() => ProfessionalApplication(
        serviceCategory: serviceCategory,
        experienceLevel: experienceLevel,
        workDescription: workDescription,
        categoryId: categoryId,
        cityId: cityId,
        serviceAreaId: serviceAreaId,
        services: services,
        profileImagePath: profileImagePath,
        idImagePath: idImagePath,
        certificationImagePath: certificationImagePath,
        conductImagePath: conductImagePath,
      );

  @override
  List<Object?> get props => [
        serviceCategory,
        categoryId,
        experienceLevel,
        workDescription,
        cityId,
        serviceAreaId,
        services,
        profileImagePath,
        idImagePath,
        certificationImagePath,
        conductImagePath,
      ];
}

// ── Cities ────────────────────────────────────────────────────────────────────

class CitiesLoading extends BecomeProfessionalState {}

class CitiesLoaded extends BecomeProfessionalState {
  final List<City> cities;
  CitiesLoaded(this.cities);
  @override
  List<Object?> get props => [cities];
}

// ── Areas ─────────────────────────────────────────────────────────────────────

class AreasLoading extends BecomeProfessionalState {}

class AreasLoaded extends BecomeProfessionalState {
  final List<ServiceArea> areas;
  AreasLoaded(this.areas);
  @override
  List<Object?> get props => [areas];
}

// ── Category services ─────────────────────────────────────────────────────────

class CategoryServicesLoading extends BecomeProfessionalState {}

class CategoryServicesLoaded extends BecomeProfessionalState {
  final List<ServiceOffered> services;
  CategoryServicesLoaded(this.services);
  @override
  List<Object?> get props => [services];
}

// ── Submission ────────────────────────────────────────────────────────────────

class BecomeProfessionalSubmitting extends BecomeProfessionalState {}

class BecomeProfessionalSuccess extends BecomeProfessionalState {}

class BecomeProfessionalError extends BecomeProfessionalState {
  final String message;
  BecomeProfessionalError(this.message);
  @override
  List<Object?> get props => [message];
}
