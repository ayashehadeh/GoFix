import 'package:equatable/equatable.dart';
import 'package:gp/core/error/app_error_state.dart';
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
  final String role;

  NotificationsLoaded({
    required this.allNotifications,
    required this.showAll,
    this.role = 'customer',
  });

  /// Items shown in the list based on current tab filter
  List<NotificationItem> get visibleNotifications =>
      showAll ? allNotifications : allNotifications.where((n) => !n.isRead).toList();

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  NotificationsLoaded copyWith({
    List<NotificationItem>? allNotifications,
    bool? showAll,
    String? role,
  }) =>
      NotificationsLoaded(
        allNotifications: allNotifications ?? this.allNotifications,
        showAll: showAll ?? this.showAll,
        role: role ?? this.role,
      );

  @override
  List<Object?> get props => [allNotifications, showAll, role];
}

class NotificationsError extends NotificationsState with AppErrorState {
  final String message;
  NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}