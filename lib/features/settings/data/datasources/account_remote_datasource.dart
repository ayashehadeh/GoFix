import 'package:dio/dio.dart';
import 'package:gp/features/settings/data/models/feedback_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AccountRemoteDataSource {
  Future<void> logout();
  Future<void> deleteAccount();
  Future<void> sendFeedback(FeedbackModel feedback);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  static const String baseUrl =
      'https://gofix-api-ceaaewf7hua0ghez.uaenorth-01.azurewebsites.net/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Future<void> logout() async {
    // TODO: call API if backend has logout endpoint
    // final token = await _getToken();
    // await _dio.post('/auth/logout',
    //     options: Options(headers: {'Authorization': 'Bearer $token'}));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> deleteAccount() async {
    // TODO: wire to real API when endpoint is ready
    // final token = await _getToken();
    // await _dio.delete('/auth/account',
    //     options: Options(headers: {'Authorization': 'Bearer $token'}));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> sendFeedback(FeedbackModel feedback) async {
    // TODO: wire to real API when endpoint is ready
    // final token = await _getToken();
    // await _dio.post('/feedback',
    //     data: feedback.toJson(),
    //     options: Options(headers: {'Authorization': 'Bearer $token'}));
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
