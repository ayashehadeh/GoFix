import 'package:gp/features/professionals/domain/entities/service_area.dart';

class ServiceAreaModel extends ServiceArea {
  const ServiceAreaModel({
    required super.id,
    required super.name,
    required super.cityId,
  });

  factory ServiceAreaModel.fromJson(Map<String, dynamic> json) {
    return ServiceAreaModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      cityId: (json['cityId'] as num? ?? json['city_id'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cityId': cityId,
  };
}