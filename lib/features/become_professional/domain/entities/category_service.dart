import 'package:equatable/equatable.dart';

/// A service offering available under a category (e.g. "Pipe Installation"
/// under "Plumbing"). Returned by GET /api/professionals/services?categoryId=
class CategoryService extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final int categoryId;

  const CategoryService({
    required this.id,
    required this.name,
    this.nameAr,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, name, nameAr, categoryId];
}
