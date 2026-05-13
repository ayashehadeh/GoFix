/* import '../models/notification_model.dart';
import '../../domain/entities/notification_item.dart';
import 'notifications_remote_datasource.dart';

/// Drop-in replacement for [NotificationsRemoteDataSourceImpl].
/// Returns hard-coded data so the UI can be developed and demoed
/// without a running backend.  Swap back to the real impl in
/// [injection_container.dart] when the API is ready.
class MockNotificationsDataSource implements NotificationsRemoteDataSource {
  // In-memory mutable list so mark-as-read actually changes state.
  final List<NotificationModel> _items = [
    // ── Today ──────────────────────────────────────────────────────────────
    NotificationModel(
      id: 'n1',
      title: 'Ahmad Khalil',
      body:
          "I'll be there at 3:00 PM, please make sure the water valve is accessible.",
      type: NotificationType.message,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Booking Confirmed',
      body:
          'Omar Amer accepted your plumbing request for Tomorrow, Feb 19 at 2:00 PM.',
      type: NotificationType.bookingConfirmed,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),

    // ── Yesterday ──────────────────────────────────────────────────────────
    NotificationModel(
      id: 'n3',
      title: 'Booking Confirmed',
      body:
          'Omar Amer accepted your plumbing request for Tomorrow, Feb 19 at 2:00 PM.',
      type: NotificationType.bookingConfirmed,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    ),
    NotificationModel(
      id: 'n4',
      title: 'Booking Declined',
      body:
          'Khalid Nasser is unavailable for your carpentry request on Feb 15. Tap to find another professional.',
      type: NotificationType.bookingDeclined,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    ),
    NotificationModel(
      id: 'n5',
      title: 'Omar Amer',
      body: 'Do you need me to bring any specific materials?',
      type: NotificationType.message,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
    ),

    // ── Earlier ────────────────────────────────────────────────────────────
    NotificationModel(
      id: 'n6',
      title: 'Booking Reminder',
      body:
          'Your appointment with Ali Emad is tomorrow at 10:00 AM. Be ready!',
      type: NotificationType.bookingReminder,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      id: 'n7',
      title: 'Ahmad Khalil',
      body: 'Job completed! Please rate your experience.',
      type: NotificationType.message,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    NotificationModel(
      id: 'n8',
      title: 'Booking Confirmed',
      body:
          'Ali Emad accepted your electrical request for Feb 10 at 11:00 AM.',
      type: NotificationType.bookingConfirmed,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  /* @override
  Future<List<NotificationModel>> getNotifications() async {
    // Simulate a brief network delay so loading states are visible.
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_items);
  } */

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _items[index] = NotificationModel(
        id: _items[index].id,
        title: _items[index].title,
        body: _items[index].body,
        type: _items[index].type,
        isRead: true,
        createdAt: _items[index].createdAt,
      );
    }
  }
/* 
  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _items.length; i++) {
      _items[i] = NotificationModel(
        id: _items[i].id,
        title: _items[i].title,
        body: _items[i].body,
        type: _items[i].type,
        isRead: true,
        createdAt: _items[i].createdAt,
      );
    }
  } */
}
 */