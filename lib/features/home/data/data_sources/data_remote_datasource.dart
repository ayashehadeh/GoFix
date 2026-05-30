import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../models/featured_banner_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<FeaturedBannerModel>> getFeaturedBanners();
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

  @override
  Future<List<FeaturedBannerModel>> getFeaturedBanners() async {
    final response = await dio.get('/featured');
    final data = response.data;
    final List<dynamic> list = data is List ? data : (data['data'] as List? ?? []);
    return list.map((e) => FeaturedBannerModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}