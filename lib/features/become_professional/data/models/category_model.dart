import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
