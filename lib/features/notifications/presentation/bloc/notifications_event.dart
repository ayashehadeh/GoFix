import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

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

class MarkAllAsReadEvent extends NotificationsEvent {}
