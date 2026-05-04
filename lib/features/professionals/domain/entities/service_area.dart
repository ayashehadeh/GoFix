import 'package:equatable/equatable.dart';

class ServiceArea extends Equatable {
  final int id;
  final String name;
  final int cityId;

  const ServiceArea({
    required this.id,
    required this.name,
    required this.cityId,
  });

  @override
  List<Object?> get props => [id, name, cityId];
}