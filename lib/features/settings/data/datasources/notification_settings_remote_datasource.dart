import 'package:dio/dio.dart';
import 'package:gp/features/settings/data/models/notification_settings_model.dart';

abstract class NotificationSettingsRemoteDataSource {
  Future<NotificationSettingsModel> getNotificationSettings();
  Future<void> updateNotificationSettings(NotificationSettingsModel settings);
}

class NotificationSettingsRemoteDataSourceImpl
    implements NotificationSettingsRemoteDataSource {
  final Dio dio;

  NotificationSettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    final response = await dio.get('/settings/notification-settings');
    final data = response.data['data'];
    return NotificationSettingsModel.fromJson(data);
  }

  @override
  Future<void> updateNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    await dio.put(
      '/settings/notification-settings',
      data: settings.toJson(),
    );
  }
}
