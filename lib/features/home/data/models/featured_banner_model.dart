import '../../domain/entities/featured_banner_entity.dart';

class FeaturedBannerModel extends FeaturedBannerEntity {
  const FeaturedBannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.label,
    super.imageUrl,
    super.categoryId,
  });

  factory FeaturedBannerModel.fromJson(Map<String, dynamic> json) {
    return FeaturedBannerModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      label: json['label'] as String? ?? 'FEATURED',
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as int?,
    );
  }
}
