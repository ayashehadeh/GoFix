import 'package:equatable/equatable.dart';

/// A service the user has added with a price range.
/// `maxPrice` is optional — null means a fixed price.
class ServicePricing extends Equatable {
  final int serviceId;
  final String serviceName;
  final String? serviceNameAr;
  final double minPrice;
  final double? maxPrice;

  const ServicePricing({
    required this.serviceId,
    required this.serviceName,
    this.serviceNameAr,
    required this.minPrice,
    this.maxPrice,
  });

  bool get isFixedPrice => maxPrice == null;

  /// e.g. "30 JD" or "30 - 40 JD"
  String get priceDisplay => isFixedPrice ? '${minPrice.toInt()} JD' : '${minPrice.toInt()} - ${maxPrice!.toInt()} JD';

  ServicePricing copyWith({
    int? serviceId,
    String? serviceName,
    String? serviceNameAr,
    double? minPrice,
    double? maxPrice,
    bool clearMaxPrice = false,
  }) {
    return ServicePricing(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceNameAr: serviceNameAr ?? this.serviceNameAr,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  @override
  List<Object?> get props => [serviceId, serviceName, minPrice, maxPrice];
}
