import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/data/datasources/notification_settings_remote_datasource.dart';
import 'package:gp/features/settings/data/models/notification_settings_model.dart';
import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:gp/features/settings/domain/repositories/notification_settings_repository.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final NotificationSettingsRemoteDataSource remoteDataSource;

  NotificationSettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, NotificationSettingsEntity>>
      getNotificationSettings() async {
    try {
      final result = await remoteDataSource.getNotificationSettings();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNotificationSettings(
    NotificationSettingsEntity settings,
  ) async {
    try {
      final model = NotificationSettingsModel.fromEntity(settings);
      await remoteDataSource.updateNotificationSettings(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
