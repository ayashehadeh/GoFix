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
    final data = response.data['data'] as Map<String, dynamic>;
    return {
      'daily': EarningModel.fromJson(data['daily'] as Map<String, dynamic>),
      'weekly': EarningModel.fromJson(data['weekly'] as Map<String, dynamic>),
      'monthly': EarningModel.fromJson(data['monthly'] as Map<String, dynamic>),
    };
  }
}
