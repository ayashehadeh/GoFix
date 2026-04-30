import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.id,
    required super.name,
    required super.role,
    required super.yearsExperience,
    super.imageUrl,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ??
          json['category'] as String? ??
          '',
      yearsExperience: json['yearsExperience'] as int? ??
          json['years_experience'] as int? ??
          json['experienceYears'] as int? ??
          0,
      imageUrl: json['imageUrl'] as String? ??
          json['image_url'] as String? ??
          json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'years_experience': yearsExperience,
        'image_url': imageUrl,
      };
}
