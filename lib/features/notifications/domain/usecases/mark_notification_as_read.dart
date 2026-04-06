import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationAsRead {
  final NotificationsRepository repository;
  const MarkNotificationAsRead(this.repository);

  Future<Either<Failure, void>> call(String notificationId) =>
      repository.markAsRead(notificationId);
}
