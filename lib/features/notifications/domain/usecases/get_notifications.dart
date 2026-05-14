import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_item.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  final NotificationsRepository repository;
  const GetNotifications(this.repository);

  Future<Either<Failure, List<NotificationItem>>> call({
    String role = 'customer',
  }) =>
      repository.getNotifications(role: role);
}