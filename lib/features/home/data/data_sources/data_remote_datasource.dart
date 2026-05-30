import 'package:dio/dio.dart';
import 'package:gp/core/services/cache_service.dart';
import '../models/category_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  final CacheService cache;

  HomeRemoteDataSourceImpl({required this.dio, required this.cache});

  @override
  Future<List<CategoryModel>> getCategories() async {
    const key = 'categories';
    final cached = cache.get<List<CategoryModel>>(key);
    if (cached != null) return cached;

    final response = await dio.get('/categories');
    final List<dynamic> data = response.data['data'];
    final result = data.map((e) => CategoryModel.fromJson(e)).toList();
    cache.set(key, result);
    return result;
  }
}
