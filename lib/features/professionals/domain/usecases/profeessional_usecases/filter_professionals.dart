import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/professional.dart';
import '../../entities/service_category.dart';
import '../../repositories/professionals_repository.dart';

class FilterProfessionals {
  final ProfessionalsRepository repository;

  const FilterProfessionals(this.repository);

  Future<Either<Failure, List<Professional>>> call({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  }) {
    return repository.filterProfessionals(
      category: category,
      minExperienceYears: minExperienceYears,
      maxDistanceKm: maxDistanceKm,
      minRating: minRating,
    );
  }
}
