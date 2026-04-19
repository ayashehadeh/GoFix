import 'package:equatable/equatable.dart';
import '../../domain/entities/professional_application.dart';
import 'become_professional_event.dart';

abstract class BecomeProfessionalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BecomeProfessionalInitial extends BecomeProfessionalState {}

/// Holds the in-progress form data across all 3 steps.
/// The UI rebuilds from this so each step is always pre-filled.
class BecomeProfessionalFormState extends BecomeProfessionalState {
  final String serviceCategory;
  final String experienceLevel;
  final String workDescription;
  final List<ServicePricing> services;
  final String? profileImagePath;
  final String? idImagePath;
  final String? certificationImagePath;
  final String? conductImagePath;

  BecomeProfessionalFormState({
    this.serviceCategory = '',
    this.experienceLevel = '',
    this.workDescription = '',
    this.services = const [],
    this.profileImagePath,
    this.idImagePath,
    this.certificationImagePath,
    this.conductImagePath,
  });

  /// Returns the path for the given document type.
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
    String? experienceLevel,
    String? workDescription,
    List<ServicePricing>? services,
    String? profileImagePath,
    String? idImagePath,
    String? certificationImagePath,
    String? conductImagePath,
  }) {
    return BecomeProfessionalFormState(
      serviceCategory: serviceCategory ?? this.serviceCategory,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      workDescription: workDescription ?? this.workDescription,
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
        services: services,
        profileImagePath: profileImagePath,
        idImagePath: idImagePath,
        certificationImagePath: certificationImagePath,
        conductImagePath: conductImagePath,
      );

  @override
  List<Object?> get props => [
        serviceCategory,
        experienceLevel,
        workDescription,
        services,
        profileImagePath,
        idImagePath,
        certificationImagePath,
        conductImagePath,
      ];
}

class BecomeProfessionalSubmitting extends BecomeProfessionalState {}

class BecomeProfessionalSuccess extends BecomeProfessionalState {}

class BecomeProfessionalError extends BecomeProfessionalState {
  final String message;
  BecomeProfessionalError(this.message);

  @override
  List<Object?> get props => [message];
}
