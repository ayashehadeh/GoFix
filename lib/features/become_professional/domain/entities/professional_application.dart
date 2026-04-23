import 'package:equatable/equatable.dart';

class ProfessionalApplication extends Equatable {
  final String serviceCategory;
  final String experienceLevel;
  final String workDescription;
  final List<ServicePricing> services;
  final String? profileImagePath;
  final String? idImagePath;
  final String? certificationImagePath;
  final String? conductImagePath;

  const ProfessionalApplication({
    required this.serviceCategory,
    required this.experienceLevel,
    required this.workDescription,
    required this.services,
    this.profileImagePath,
    this.idImagePath,
    this.certificationImagePath,
    this.conductImagePath,
  });

  ProfessionalApplication copyWith({
    String? serviceCategory,
    String? experienceLevel,
    String? workDescription,
    List<ServicePricing>? services,
    String? profileImagePath,
    String? idImagePath,
    String? certificationImagePath,
    String? conductImagePath,
  }) {
    return ProfessionalApplication(
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

class ServicePricing extends Equatable {
  final String serviceName;
  final double price;

  const ServicePricing({required this.serviceName, required this.price});

  @override
  List<Object?> get props => [serviceName, price];
}
