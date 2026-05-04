import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/become_professional_repository.dart';

class CreateProfile {
  final BecomeProfessionalRepository repository;
  const CreateProfile(this.repository);

  Future<Either<Failure, Unit>> call({
    required int categoryId,
    required int experienceYears,
    required int cityId,
    required int serviceAreaId,
    required String bio,
  }) =>
      repository.createProfile(
        categoryId: categoryId,
        experienceYears: experienceYears,
        cityId: cityId,
        serviceAreaId: serviceAreaId,
        bio: bio,
      );
}
