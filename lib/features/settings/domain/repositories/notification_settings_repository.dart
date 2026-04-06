import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';

abstract class NotificationSettingsRepository {
  Future<Either<Failure, NotificationSettingsEntity>> getNotificationSettings();
  Future<Either<Failure, Unit>> updateNotificationSettings(
    NotificationSettingsEntity settings,
  );
}
