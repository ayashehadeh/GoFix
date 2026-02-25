import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String iconAsset; // path to local SVG asset

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconAsset,
  });

  @override
  List<Object> get props => [id, name, iconAsset];
}
