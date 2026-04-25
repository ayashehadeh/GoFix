import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  /// Searches both professionals by name AND areas by name in one call.
  Future<Either<Failure, SearchResults>> search(String query);

  /// Returns all professionals that serve a given area,
  /// optionally filtered by [category].
  Future<Either<Failure, List<Professional>>> getProfessionalsByArea({
    required String areaName,
    ServiceCategory? category,
  });
}
