import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkAllNotificationsAsRead {
  final NotificationsRepository repository;
  const MarkAllNotificationsAsRead(this.repository);

  Future<Either<Failure, void>> call({String role = 'customer'}) =>
      repository.markAllAsRead(role: role);
}