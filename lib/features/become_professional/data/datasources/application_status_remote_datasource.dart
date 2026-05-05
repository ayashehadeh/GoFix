import 'package:dio/dio.dart';
import '../models/application_status_model.dart';

abstract class ApplicationStatusRemoteDataSource {
  Future<ApplicationStatusModel> getApplicationStatus();
}

class ApplicationStatusRemoteDataSourceImpl
    implements ApplicationStatusRemoteDataSource {
  final Dio dio;
  const ApplicationStatusRemoteDataSourceImpl({required this.dio});

  @override
  Future<ApplicationStatusModel> getApplicationStatus() async {
    final response = await dio.get('/professionals/profile/status');
    return ApplicationStatusModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
