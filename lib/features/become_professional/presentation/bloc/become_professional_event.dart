import 'package:equatable/equatable.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/service_pricing.dart';

abstract class BecomeProfessionalEvent extends Equatable {
  const BecomeProfessionalEvent();
  @override
  List<Object?> get props => [];
}

// ── Lookups ───────────────────────────────────────────────────────────────────

/// Fired when the flow opens — fetches categories + service areas in parallel.
class LoadInitialData extends BecomeProfessionalEvent {
  const LoadInitialData();
}

/// Fired when the user picks a category on Step 1 — preloads its services
/// so Step 2 has them ready.
class LoadServicesForCategory extends BecomeProfessionalEvent {
  final int categoryId;
  const LoadServicesForCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

// ── Step 1 ────────────────────────────────────────────────────────────────────

/// Each Step 1 field has its own update event so we can refresh dependent UI
/// (e.g. selecting a city resets the area).
class CategorySelected extends BecomeProfessionalEvent {
  final int categoryId;
  final String categoryName;
  const CategorySelected({
    required this.categoryId,
    required this.categoryName,
  });
  @override
  List<Object?> get props => [categoryId, categoryName];
}

class ExperienceYearsSelected extends BecomeProfessionalEvent {
  final int years;
  const ExperienceYearsSelected(this.years);
  @override
  List<Object?> get props => [years];
}

class CitySelected extends BecomeProfessionalEvent {
  final int cityId;
  final String cityName;
  const CitySelected({required this.cityId, required this.cityName});
  @override
  List<Object?> get props => [cityId, cityName];
}

class ServiceAreaSelected extends BecomeProfessionalEvent {
  final int serviceAreaId;
  final String serviceAreaName;
  const ServiceAreaSelected({
    required this.serviceAreaId,
    required this.serviceAreaName,
  });
  @override
  List<Object?> get props => [serviceAreaId, serviceAreaName];
}

class BioChanged extends BecomeProfessionalEvent {
  final String bio;
  const BioChanged(this.bio);
  @override
  List<Object?> get props => [bio];
}

/// Submit Step 1 — calls POST /api/professionals/profile and advances on success.
class SubmitStep1 extends BecomeProfessionalEvent {
  const SubmitStep1();
}

// ── Step 2 ────────────────────────────────────────────────────────────────────

class ServiceAdded extends BecomeProfessionalEvent {
  final ServicePricing service;
  const ServiceAdded(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceRemoved extends BecomeProfessionalEvent {
  final int serviceId;
  const ServiceRemoved(this.serviceId);
  @override
  List<Object?> get props => [serviceId];
}

/// Submit Step 2 — calls PUT /api/professionals/profile/services.
class SubmitStep2 extends BecomeProfessionalEvent {
  const SubmitStep2();
}

// ── Step 3 ────────────────────────────────────────────────────────────────────

/// Stores the locally-picked file path. Upload happens on its dedicated page.
class ProfilePicturePicked extends BecomeProfessionalEvent {
  final String filePath;
  const ProfilePicturePicked(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

class DocumentPicked extends BecomeProfessionalEvent {
  final DocumentType documentType;
  final String filePath;
  const DocumentPicked({
    required this.documentType,
    required this.filePath,
  });
  @override
  List<Object?> get props => [documentType, filePath];
}

/// Uploads the profile picture file (POST /api/auth/profile-picture).
class UploadProfilePictureRequested extends BecomeProfessionalEvent {
  const UploadProfilePictureRequested();
}

/// Uploads a single document (POST /api/professionals/profile/documents).
class UploadDocumentRequested extends BecomeProfessionalEvent {
  final DocumentType documentType;
  const UploadDocumentRequested(this.documentType);
  @override
  List<Object?> get props => [documentType];
}

/// Final submission — calls POST /api/professionals/profile/submit.
class SubmitApplicationRequested extends BecomeProfessionalEvent {
  const SubmitApplicationRequested();
}
