import 'package:equatable/equatable.dart';

class ServiceArea extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final int cityId;
  final String? cityName;

  const ServiceArea({
    required this.id,
    required this.name,
    this.nameAr,
    required this.cityId,
    this.cityName,
  });

  @override
  List<Object?> get props => [id, name, nameAr, cityId, cityName];
}
