import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_status_entity.dart';

abstract class ApplicationStatusRepository {
  /// GET /api/professionals/profile/status
  Future<Either<Failure, ApplicationStatusEntity>> getApplicationStatus();
}
