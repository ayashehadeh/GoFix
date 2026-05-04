import '../../domain/entities/service_pricing.dart';

class ServicePricingModel extends ServicePricing {
  const ServicePricingModel({
    required super.serviceId,
    required super.serviceName,
    required super.minPrice,
    super.maxPrice,
  });

  factory ServicePricingModel.fromEntity(ServicePricing entity) {
    return ServicePricingModel(
      serviceId: entity.serviceId,
      serviceName: entity.serviceName,
      minPrice: entity.minPrice,
      maxPrice: entity.maxPrice,
    );
  }

  /// Payload shape expected by PUT /api/professionals/profile/services
  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
      };
}
