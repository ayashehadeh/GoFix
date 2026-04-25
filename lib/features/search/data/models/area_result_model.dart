import 'package:gp/features/search/domain/entities/search_result.dart';

class AreaResultModel extends AreaResult {
  const AreaResultModel({
    required super.name,
    required super.city,
    required super.proCount,
  });

  factory AreaResultModel.fromJson(Map<String, dynamic> json) {
    return AreaResultModel(
      name: json['name'] as String,
      city: json['city'] as String,
      proCount: json['proCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'proCount': proCount,
      };
}
