import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/professional_application.dart';

abstract class BecomeProfessionalRepository {
  Future<Either<Failure, void>> submitApplication(
    ProfessionalApplication application,
  );
}
