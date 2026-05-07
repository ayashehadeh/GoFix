import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/become_professional_repository.dart';

class CreateProfile {
  final BecomeProfessionalRepository repository;
  const CreateProfile(this.repository);

  Future<Either<Failure, Unit>> call({
    required int categoryId,
    required int experienceYears,
    double? latitude,
    double? longitude,
    required String bio,
  }) =>
      repository.createProfile(
        categoryId: categoryId,
        experienceYears: experienceYears,
        latitude: latitude,
        longitude: longitude,
        bio: bio,
      );
}
