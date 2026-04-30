import 'package:equatable/equatable.dart';

enum AddressType { apartment, house }

class AddressEntity extends Equatable {
  final String id;
  final AddressType type;
  final String area;
  final String street;
  final String? buildingName;
  final String? apartmentNumber;
  final String? floor;
  final String? house;
  final String? additionalDirections;
  final double latitude;
  final double longitude;

  const AddressEntity({
    required this.id,
    required this.type,
    required this.area,
    required this.street,
    this.buildingName,
    this.apartmentNumber,
    this.floor,
    this.house,
    this.additionalDirections,
    required this.latitude,
    required this.longitude,
  });

  String get displayTitle {
    final typeLabel = type == AddressType.apartment ? 'Apartment' : 'House';
    return '$typeLabel, $area';
  }

  String get displaySubtitle {
    if (type == AddressType.apartment) {
      return '$street, ${buildingName ?? ''}';
    } else {
      return '$street, ${house ?? ''}';
    }
  }

  AddressEntity copyWith({
    String? id,
    AddressType? type,
    String? area,
    String? street,
    String? buildingName,
    String? apartmentNumber,
    String? floor,
    String? house,
    String? additionalDirections,
    double? latitude,
    double? longitude,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      area: area ?? this.area,
      street: street ?? this.street,
      buildingName: buildingName ?? this.buildingName,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      floor: floor ?? this.floor,
      house: house ?? this.house,
      additionalDirections: additionalDirections ?? this.additionalDirections,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        area,
        street,
        buildingName,
        apartmentNumber,
        floor,
        house,
        additionalDirections,
        latitude,
        longitude,
      ];
}
