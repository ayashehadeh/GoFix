import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import '../entities/search_result.dart';

// Simple value object for a saved recent search
class RecentSearch {
  final String id;
  final String query;
  const RecentSearch({required this.id, required this.query});
}

abstract class SearchRepository {
  /// Unified search: professionals by name, services by name, areas by name.
  Future<Either<Failure, SearchResults>> search(String query);

  /// Professionals that serve a given area, optionally filtered by category.
  Future<Either<Failure, List<Professional>>> getProfessionalsByArea({
    required String areaName,
    ServiceCategory? category,
  });

  // ── Recent searches (auth-gated on backend) ───────────────────────────────

  Future<Either<Failure, List<RecentSearch>>> getRecentSearches();
  Future<Either<Failure, void>> recordSearch(String query);
  Future<Either<Failure, void>> deleteRecentSearch(String id);
  Future<Either<Failure, void>> clearRecentSearches();
}