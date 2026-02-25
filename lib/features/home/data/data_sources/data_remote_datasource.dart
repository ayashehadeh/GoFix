import 'package:dio/dio.dart';
import '../models/category_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    // TODO: Replace with real endpoint once backend is ready
    // final response = await dio.get('/categories');
    // return (response.data as List).map((e) => CategoryModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockCategories;
  }
}

final _mockCategories = [
  CategoryModel(id: 1, name: 'Plumbing',         iconAsset: 'assets/home_screen/plumbing.svg'),
  CategoryModel(id: 2, name: 'Electrical Work',  iconAsset: 'assets/home_screen/electrical_services.svg'),
  CategoryModel(id: 3, name: 'AC Repair',        iconAsset: 'assets/home_screen/toys.svg'),
  CategoryModel(id: 4, name: 'Carpentry',        iconAsset: 'assets/home_screen/handyman.svg'),
  CategoryModel(id: 5, name: 'Painting',         iconAsset: 'assets/home_screen/format_paint.svg'),
  CategoryModel(id: 6, name: 'Cleaning',         iconAsset: 'assets/home_screen/cleaning_services.svg'),
  CategoryModel(id: 7, name: 'Moving Services',  iconAsset: 'assets/home_screen/local_shipping.svg'),
  CategoryModel(id: 8, name: 'Appliance Repair', iconAsset: 'assets/home_screen/home_repair_service.svg'),
];