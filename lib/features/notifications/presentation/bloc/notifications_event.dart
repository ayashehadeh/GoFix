import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final String role;
  LoadNotifications({this.role = 'customer'});

  @override
  List<Object?> get props => [role];
}

class SwitchNotificationsFilter extends NotificationsEvent {
  /// true = show all, false = show unread only
  final bool showAll;
  SwitchNotificationsFilter(this.showAll);

  @override
  List<Object?> get props => [showAll];
}

class MarkAsReadEvent extends NotificationsEvent {
  final String notificationId;
  MarkAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsReadEvent extends NotificationsEvent {
  final String role;
  MarkAllAsReadEvent({this.role = 'customer'});

  @override
  List<Object?> get props => [role];
}