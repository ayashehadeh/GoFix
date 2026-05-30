import 'package:equatable/equatable.dart';

class FeaturedBannerEntity extends Equatable {
  final int id;
  final String title;
  final String subtitle;
  final String label;
  final String? imageUrl;
  final int? categoryId;

  const FeaturedBannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.label,
    this.imageUrl,
    this.categoryId,
  });

  @override
  List<Object?> get props => [id, title, subtitle, label, imageUrl, categoryId];
}
