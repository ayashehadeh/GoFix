import 'dart:convert';
import 'package:gp/features/settings/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.type,
    required super.area,
    required super.street,
    super.buildingName,
    super.apartmentNumber,
    super.floor,
    super.house,
    super.additionalDirections,
    required super.latitude,
    required super.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      type: json['type'] == 'apartment'
          ? AddressType.apartment
          : AddressType.house,
      area: json['area'] as String,
      street: json['street'] as String,
      buildingName: json['buildingName'] as String?,
      apartmentNumber: json['apartmentNumber'] as String?,
      floor: json['floor'] as String?,
      house: json['house'] as String?,
      additionalDirections: json['additionalDirections'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == AddressType.apartment ? 'apartment' : 'house',
      'area': area,
      'street': street,
      'buildingName': buildingName,
      'apartmentNumber': apartmentNumber,
      'floor': floor,
      'house': house,
      'additionalDirections': additionalDirections,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      type: entity.type,
      area: entity.area,
      street: entity.street,
      buildingName: entity.buildingName,
      apartmentNumber: entity.apartmentNumber,
      floor: entity.floor,
      house: entity.house,
      additionalDirections: entity.additionalDirections,
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  static List<AddressModel> listFromJson(String jsonStr) {
    final list = json.decode(jsonStr) as List;
    return list.map((e) => AddressModel.fromJson(e)).toList();
  }

  static String listToJson(List<AddressModel> models) {
    return json.encode(models.map((e) => e.toJson()).toList());
  }
}
