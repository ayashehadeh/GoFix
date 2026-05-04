import 'package:equatable/equatable.dart';

class ProfessionalApplication extends Equatable {
  final String serviceCategory;
  final String experienceLevel;
  final String workDescription;
  final int categoryId;
  final int cityId;
  final int serviceAreaId;
  final List<ServicePricing> services;
  final String? profileImagePath;
  final String? idImagePath;
  final String? certificationImagePath;
  final String? conductImagePath;

  const ProfessionalApplication({
    required this.serviceCategory,
    required this.experienceLevel,
    required this.workDescription,
    required this.categoryId,
    required this.cityId,
    required this.serviceAreaId,
    required this.services,
    this.profileImagePath,
    this.idImagePath,
    this.certificationImagePath,
    this.conductImagePath,
  });

  @override
  List<Object?> get props => [
        serviceCategory,
        experienceLevel,
        workDescription,
        categoryId,
        cityId,
        serviceAreaId,
        services,
        profileImagePath,
        idImagePath,
        certificationImagePath,
        conductImagePath,
      ];
}

// A single service offering with min/max price (in JD)
class ServicePricing extends Equatable {
  final int serviceId;
  final String serviceName;
  final double minPrice;
  final double? maxPrice;

  const ServicePricing({
    required this.serviceId,
    required this.serviceName,
    required this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [serviceId, serviceName, minPrice, maxPrice];
}
