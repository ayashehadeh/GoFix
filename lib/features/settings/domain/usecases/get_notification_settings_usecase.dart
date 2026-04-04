import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:gp/features/settings/domain/repositories/notification_settings_repository.dart';

class GetNotificationSettingsUseCase {
  final NotificationSettingsRepository repository;

  GetNotificationSettingsUseCase(this.repository);

  Future<Either<Failure, NotificationSettingsEntity>> call() {
    return repository.getNotificationSettings();
  }
}
