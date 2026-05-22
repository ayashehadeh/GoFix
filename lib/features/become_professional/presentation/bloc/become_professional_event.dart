import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/service_pricing.dart';

abstract class BecomeProfessionalEvent extends Equatable {
  const BecomeProfessionalEvent();
  @override
  List<Object?> get props => [];
}

// ── Lookups ───────────────────────────────────────────────────────────────────

class LoadInitialData extends BecomeProfessionalEvent {
  const LoadInitialData();
}

class LoadServicesForCategory extends BecomeProfessionalEvent {
  final int categoryId;
  const LoadServicesForCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

// ── Step 1 ────────────────────────────────────────────────────────────────────

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

class ServiceAreaToggled extends BecomeProfessionalEvent {
  final int serviceAreaId;
  final String serviceAreaName;
  const ServiceAreaToggled({
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

class SubmitStep2 extends BecomeProfessionalEvent {
  const SubmitStep2();
}

// ── Step 3 – Documents ────────────────────────────────────────────────────────

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

/// Upload profile picture — carries the path directly to avoid race condition.
class UploadProfilePictureWithPathRequested extends BecomeProfessionalEvent {
  final String filePath;
  const UploadProfilePictureWithPathRequested(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

/// Upload a document — carries the path directly to avoid race condition.
class UploadDocumentWithPathRequested extends BecomeProfessionalEvent {
  final DocumentType documentType;
  final String filePath;
  const UploadDocumentWithPathRequested({
    required this.documentType,
    required this.filePath,
  });
  @override
  List<Object?> get props => [documentType, filePath];
}

/// Final submission — calls POST /api/professionals/profile/submit.
class SubmitApplicationRequested extends BecomeProfessionalEvent {
  const SubmitApplicationRequested();
}

/// Pre-fills the bloc state from an already-fetched Professional profile
/// (used by the Edit Profile wizard so fields are pre-populated).
class PreloadProfileData extends BecomeProfessionalEvent {
  final Professional professional;
  const PreloadProfileData(this.professional);
  @override
  List<Object?> get props => [professional];
}