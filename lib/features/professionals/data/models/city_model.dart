import 'package:gp/features/professionals/domain/entities/city.dart';

class CityModel extends City {
  const CityModel({required super.id, required super.name, super.nameAr});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (nameAr != null) 'nameAr': nameAr,
  };
}