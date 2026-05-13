import 'package:dio/dio.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({String role = 'customer'});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead({String role = 'customer'});
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final Dio dio;

  const NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications(
      {String role = 'customer'}) async {
    final response = await dio.get(
      '/notifications',
      queryParameters: {'role': role},
    );
    final data = response.data['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await dio.put('/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead({String role = 'customer'}) async {
    await dio.put(
      '/notifications/read-all',
      queryParameters: {'role': role},
    );
  }
}