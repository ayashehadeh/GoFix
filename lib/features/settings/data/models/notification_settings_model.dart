import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';

class NotificationSettingsModel extends NotificationSettingsEntity {
  const NotificationSettingsModel({
    required super.bookingConfirmations,
    required super.modificationsCancellations,
    required super.chatMessages,
    required super.supportComplaints,
    required super.appFeedback,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      bookingConfirmations: json['bookingConfirmations'] as bool? ?? false,
      modificationsCancellations:
          json['modificationsCancellations'] as bool? ?? false,
      chatMessages: json['chatMessages'] as bool? ?? false,
      supportComplaints: json['supportComplaints'] as bool? ?? false,
      appFeedback: json['appFeedback'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingConfirmations': bookingConfirmations,
      'modificationsCancellations': modificationsCancellations,
      'chatMessages': chatMessages,
      'supportComplaints': supportComplaints,
      'appFeedback': appFeedback,
    };
  }

  factory NotificationSettingsModel.fromEntity(
    NotificationSettingsEntity entity,
  ) {
    return NotificationSettingsModel(
      bookingConfirmations: entity.bookingConfirmations,
      modificationsCancellations: entity.modificationsCancellations,
      chatMessages: entity.chatMessages,
      supportComplaints: entity.supportComplaints,
      appFeedback: entity.appFeedback,
    );
  }
}
