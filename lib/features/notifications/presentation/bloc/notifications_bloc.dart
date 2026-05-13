import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/mark_all_notifications_as_read.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotifications getNotifications;
  final MarkNotificationAsRead markNotificationAsRead;
  final MarkAllNotificationsAsRead markAllNotificationsAsRead;

  NotificationsBloc({
    required this.getNotifications,
    required this.markNotificationAsRead,
    required this.markAllNotificationsAsRead,
  }) : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<SwitchNotificationsFilter>(_onSwitchFilter);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    final result = await getNotifications(role: event.role);
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (items) => emit(NotificationsLoaded(
        allNotifications: items,
        showAll: true,
        role: event.role,
      )),
    );
  }

  void _onSwitchFilter(
    SwitchNotificationsFilter event,
    Emitter<NotificationsState> emit,
  ) {
    if (state is NotificationsLoaded) {
      emit((state as NotificationsLoaded).copyWith(showAll: event.showAll));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final current = state as NotificationsLoaded;

    // Optimistic update — mark read in UI immediately
    final updated = current.allNotifications.map((n) {
      return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(current.copyWith(allNotifications: updated));

    // Fire-and-forget API call; revert on failure
    final result = await markNotificationAsRead(event.notificationId);
    result.fold(
      (_) => emit(current), // revert to previous state on error
      (_) => null,          // success — UI already updated
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final current = state as NotificationsLoaded;

    // Optimistic update
    final updated =
        current.allNotifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(current.copyWith(allNotifications: updated));

    // API call; revert on failure
    final result = await markAllNotificationsAsRead(role: event.role);
    result.fold(
      (_) => emit(current),
      (_) => null,
    );
  }
}