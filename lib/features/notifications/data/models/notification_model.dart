import '../../domain/entities/notification_item.dart';

class NotificationModel extends NotificationItem {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      type: NotificationType.fromString(
        json['type'] as String? ?? 'general',
      ),
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            json['created_at'] as String? ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };
}
