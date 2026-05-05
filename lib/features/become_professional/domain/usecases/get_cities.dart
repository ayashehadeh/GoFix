import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/city.dart';
import '../repositories/become_professional_repository.dart';

class GetCitiesFromProfessional {
  final BecomeProfessionalRepository repository;
  const GetCitiesFromProfessional(this.repository);

  Future<Either<Failure, List<City>>> call() => repository.getCities();
}