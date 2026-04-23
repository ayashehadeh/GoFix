import 'package:dio/dio.dart';
import 'package:gp/features/settings/data/models/feedback_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AccountRemoteDataSource {
  Future<void> logout();
  Future<void> deleteAccount();
  Future<void> sendFeedback(FeedbackModel feedback);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio dio;

  AccountRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> logout() async {
    // No backend endpoint needed — just clear local token
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> deleteAccount() async {
    await dio.delete('/settings/account');
    // Clear local data after successful server deletion
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> sendFeedback(FeedbackModel feedback) async {
    await dio.post('/settings/feedback', data: feedback.toJson());
  }
}
