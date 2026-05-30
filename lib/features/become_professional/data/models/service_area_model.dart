import '../../domain/entities/service_area.dart';

class ServiceAreaModel extends ServiceArea {
  const ServiceAreaModel({
    required super.id,
    required super.name,
    super.nameAr,
    required super.cityId,
    super.cityName,
  });

  factory ServiceAreaModel.fromJson(Map<String, dynamic> json) {
    // API returns service areas with cityId. City name may come from:
    // 1. A nested city object { id, name }
    // 2. Direct cityName/city_name field
    // 3. Otherwise, cityId is used (will be mapped to name on frontend)
    int cityId = 0;
    String? cityName;

    final cityField = json['city'];
    if (cityField is Map<String, dynamic>) {
      cityId = (cityField['id'] as num? ?? 0).toInt();
      cityName = cityField['name'] as String?;
    } else {
      cityId = (json['cityId'] as num? ??
              json['city_id'] as num? ??
              0)
          .toInt();
      cityName = json['cityName'] as String? ?? json['city_name'] as String?;
    }

    return ServiceAreaModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? json['name_ar'] as String?,
      cityId: cityId,
      cityName: cityName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cityId': cityId,
        if (cityName != null) 'cityName': cityName,
      };
}
