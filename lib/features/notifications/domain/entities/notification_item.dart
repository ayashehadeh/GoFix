import 'package:equatable/equatable.dart';

enum NotificationType {
  message,
  bookingConfirmed,
  bookingDeclined,
  bookingReminder,
  general;

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'booking_confirmed':
      case 'bookingconfirmed':
        return NotificationType.bookingConfirmed;
      case 'booking_declined':
      case 'bookingdeclined':
        return NotificationType.bookingDeclined;
      case 'booking_reminder':
      case 'bookingeminder':
        return NotificationType.bookingReminder;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.general;
    }
  }
}

class NotificationItem extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, title, body, type, isRead, createdAt];
}
