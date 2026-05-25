import 'package:gp/features/search/domain/entities/search_result.dart';

class AreaResultModel extends AreaResult {
  const AreaResultModel({
    required super.id,
    required super.name,
    required super.city,
    required super.proCount,
  });

  factory AreaResultModel.fromJson(Map<String, dynamic> json) {
    return AreaResultModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      proCount: (json['availableProfessionalCount'] as num? ?? json['proCount'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'proCount': proCount,
      };
}
