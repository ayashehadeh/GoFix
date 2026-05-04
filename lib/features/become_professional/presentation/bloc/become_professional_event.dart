import 'package:equatable/equatable.dart';
import '../../domain/entities/professional_application.dart';

abstract class BecomeProfessionalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// ── Data loading ──────────────────────────────────────────────────────────────

/// Load available cities from the API (fired on Step 1 init)
class LoadCities extends BecomeProfessionalEvent {}

/// Load areas for a specific city (fired when user picks a city)
class LoadAreas extends BecomeProfessionalEvent {
  final int cityId;
  LoadAreas(this.cityId);
  @override
  List<Object?> get props => [cityId];
}

/// Load services for a specific category (fired when user picks a category)
class LoadServicesForCategory extends BecomeProfessionalEvent {
  final int categoryId;
  LoadServicesForCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

// ── Form steps ────────────────────────────────────────────────────────────────

/// Step 1 — professional details
class UpdateStep1 extends BecomeProfessionalEvent {
  final String serviceCategory;
  final int categoryId;
  final String experienceLevel;
  final String workDescription;
  final int cityId;
  final int serviceAreaId;

  UpdateStep1({
    required this.serviceCategory,
    required this.categoryId,
    required this.experienceLevel,
    required this.workDescription,
    required this.cityId,
    required this.serviceAreaId,
  });

  @override
  List<Object?> get props => [
        serviceCategory,
        categoryId,
        experienceLevel,
        workDescription,
        cityId,
        serviceAreaId,
      ];
}

/// Step 2 — services & pricing
class UpdateServices extends BecomeProfessionalEvent {
  final List<ServicePricing> services;
  UpdateServices(this.services);
  @override
  List<Object?> get props => [services];
}

/// Step 3 — document uploads
class UpdateDocument extends BecomeProfessionalEvent {
  final DocumentType type;
  final String path;
  UpdateDocument({required this.type, required this.path});
  @override
  List<Object?> get props => [type, path];
}

/// Final — submit entire application to API
class SubmitApplication extends BecomeProfessionalEvent {}

// ── Enum ─────────────────────────────────────────────────────────────────────

enum DocumentType { profile, id, certification, conduct }
