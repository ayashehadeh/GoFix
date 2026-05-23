import '../../domain/entities/category_service.dart';

class CategoryServiceModel extends CategoryService {
  const CategoryServiceModel({
    required super.id,
    required super.name,
    super.nameAr,
    required super.categoryId,
  });

  factory CategoryServiceModel.fromJson(Map<String, dynamic> json) {
    return CategoryServiceModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? json['name_ar'] as String?,
      categoryId: (json['categoryId'] as num? ??
              json['category_id'] as num? ??
              0)
          .toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'categoryId': categoryId,
      };
}
