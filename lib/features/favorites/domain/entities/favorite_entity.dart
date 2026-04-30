import 'package:equatable/equatable.dart';

class FavoriteEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final int yearsExperience;
  final String? imageUrl;

  const FavoriteEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.yearsExperience,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, role, yearsExperience, imageUrl];
}
