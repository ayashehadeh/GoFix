import 'package:equatable/equatable.dart';

class ServiceOffered extends Equatable {
  final String name;
  final double minPrice;
  final double? maxPrice; // null = fixed price, non-null = price range

  const ServiceOffered({
    required this.name,
    required this.minPrice,
    this.maxPrice,
  });

  bool get isFixedPrice => maxPrice == null;

  /// e.g. "30 JD" or "30 - 40 JD"
  String get priceDisplay => isFixedPrice
      ? '${minPrice.toInt()} JD'
      : '${minPrice.toInt()} - ${maxPrice!.toInt()} JD';

  @override
  List<Object?> get props => [name, minPrice, maxPrice];
}
