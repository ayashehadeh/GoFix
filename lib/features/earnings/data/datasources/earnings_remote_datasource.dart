import 'package:dio/dio.dart';
import '../models/earning_model.dart';

abstract class EarningsRemoteDataSource {
  Future<Map<String, EarningModel>> getEarnings();
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final Dio dio;

  const EarningsRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, EarningModel>> getEarnings() async {
    final response = await dio.get('/bookings/earnings');
    final data = response.data['data'] ?? response.data;
    return {
      'daily': EarningModel.fromJson(data['daily'] ?? {}),
      'weekly': EarningModel.fromJson(data['weekly'] ?? {}),
      'monthly': EarningModel.fromJson(data['monthly'] ?? {}),
    };
  }
}
