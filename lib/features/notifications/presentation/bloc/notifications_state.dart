import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_item.dart';

abstract class NotificationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> allNotifications;
  final bool showAll;

  NotificationsLoaded({
    required this.allNotifications,
    required this.showAll,
  });

  /// Items shown in the list based on current tab filter
  List<NotificationItem> get visibleNotifications =>
      showAll ? allNotifications : allNotifications.where((n) => !n.isRead).toList();

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  NotificationsLoaded copyWith({
    List<NotificationItem>? allNotifications,
    bool? showAll,
  }) =>
      NotificationsLoaded(
        allNotifications: allNotifications ?? this.allNotifications,
        showAll: showAll ?? this.showAll,
      );

  @override
  List<Object?> get props => [allNotifications, showAll];
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
