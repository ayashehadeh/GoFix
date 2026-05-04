import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_pricing.dart';
import '../repositories/become_professional_repository.dart';

class SetServices {
  final BecomeProfessionalRepository repository;
  const SetServices(this.repository);

  Future<Either<Failure, Unit>> call(List<ServicePricing> services) =>
      repository.setServices(services);
}
