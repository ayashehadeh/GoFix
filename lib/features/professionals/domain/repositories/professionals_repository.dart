import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/professional.dart';
import '../entities/service_category.dart';

abstract class ProfessionalsRepository {
  Future<Either<Failure, List<Professional>>> getProfessionalsByCategory(
    ServiceCategory category,
  );

  Future<Either<Failure, Professional>> getProfessionalById(String id);

  Future<Either<Failure, List<Professional>>> getFavorites();

  Future<Either<Failure, void>> toggleFavorite(String professionalId);

  Future<Either<Failure, List<Professional>>> searchProfessionals(String query);

  Future<Either<Failure, List<Professional>>> filterProfessionals({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  });
}
