import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconAsset
  });
  //FROMJson
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      iconAsset: _mapNameToAsset(json['name'] as String),
    );
  }
  //ToJson
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  // Maps category name from API to local SVG asset
  static String _mapNameToAsset(String name) {
    const map = {
      'Plumbing':         'assets/home_screen/plumbing.svg',
      'Electrical Work':  'assets/home_screen/electrical_services.svg',
      'AC Repair':        'assets/home_screen/toys.svg',
      'Carpentry':        'assets/home_screen/handyman.svg',
      'Painting':         'assets/home_screen/format_paint.svg',
      'Cleaning':         'assets/home_screen/cleaning_services.svg',
      'Moving Services':  'assets/home_screen/local_shipping.svg',
      'Appliance Repair': 'assets/home_screen/home_repair_service.svg',
    };
    return map[name] ?? 'assets/home_screen/home_repair_service.svg';
  }
}