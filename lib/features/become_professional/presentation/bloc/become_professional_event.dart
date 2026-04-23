import 'package:equatable/equatable.dart';
import '../../domain/entities/professional_application.dart';

abstract class BecomeProfessionalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Step 1 — user fills in category, experience, description
class UpdateStep1 extends BecomeProfessionalEvent {
  final String serviceCategory;
  final String experienceLevel;
  final String workDescription;

  UpdateStep1({
    required this.serviceCategory,
    required this.experienceLevel,
    required this.workDescription,
  });

  @override
  List<Object?> get props => [serviceCategory, experienceLevel, workDescription];
}

/// Step 2 — user adds / removes a service+price pair
class UpdateServices extends BecomeProfessionalEvent {
  final List<ServicePricing> services;
  UpdateServices(this.services);

  @override
  List<Object?> get props => [services];
}

/// Step 3 — user uploads a document image
class UpdateDocument extends BecomeProfessionalEvent {
  final DocumentType type;
  final String path; // local file path

  UpdateDocument({required this.type, required this.path});

  @override
  List<Object?> get props => [type, path];
}

/// Final — submit the full application to the API
class SubmitApplication extends BecomeProfessionalEvent {}

enum DocumentType { profile, id, certification, conduct }
