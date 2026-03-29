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
    final response = await dio.get('/categories');
    final List<dynamic> data = response.data['data'];
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}