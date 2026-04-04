import 'package:gp/features/settings/data/models/notification_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NotificationSettingsRemoteDataSource {
  Future<NotificationSettingsModel> getNotificationSettings();
  Future<void> updateNotificationSettings(NotificationSettingsModel settings);
}

class NotificationSettingsRemoteDataSourceImpl
    implements NotificationSettingsRemoteDataSource {
  static const _keyBookingConfirmations = 'notif_bookingConfirmations';
  static const _keyModificationsCancellations =
      'notif_modificationsCancellations';
  static const _keyChatMessages = 'notif_chatMessages';
  static const _keySupportComplaints = 'notif_supportComplaints';
  static const _keyAppFeedback = 'notif_appFeedback';

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettingsModel(
      bookingConfirmations: prefs.getBool(_keyBookingConfirmations) ?? false,
      modificationsCancellations:
          prefs.getBool(_keyModificationsCancellations) ?? true,
      chatMessages: prefs.getBool(_keyChatMessages) ?? false,
      supportComplaints: prefs.getBool(_keySupportComplaints) ?? false,
      appFeedback: prefs.getBool(_keyAppFeedback) ?? true,
    );
  }

  @override
  Future<void> updateNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        _keyBookingConfirmations, settings.bookingConfirmations);
    await prefs.setBool(
        _keyModificationsCancellations, settings.modificationsCancellations);
    await prefs.setBool(_keyChatMessages, settings.chatMessages);
    await prefs.setBool(_keySupportComplaints, settings.supportComplaints);
    await prefs.setBool(_keyAppFeedback, settings.appFeedback);
  }
}
