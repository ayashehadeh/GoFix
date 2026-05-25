import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;
  const SearchUseCase(this.repository);

  Future<Either<Failure, SearchResults>> call(String query) =>
      repository.search(query);
}

class GetProfessionalsByArea {
  final SearchRepository repository;
  const GetProfessionalsByArea(this.repository);

  Future<Either<Failure, List<Professional>>> call({
    required int areaId,
    ServiceCategory? category,
  }) =>
      repository.getProfessionalsByArea(
        areaId: areaId,
        category: category,
      );
}

// ── Recent search use cases ───────────────────────────────────────────────────

class GetRecentSearchesUseCase {
  final SearchRepository repository;
  const GetRecentSearchesUseCase(this.repository);

  Future<Either<Failure, List<RecentSearch>>> call() =>
      repository.getRecentSearches();
}

class RecordSearchUseCase {
  final SearchRepository repository;
  const RecordSearchUseCase(this.repository);

  Future<Either<Failure, void>> call(String query) =>
      repository.recordSearch(query);
}

class DeleteRecentSearchUseCase {
  final SearchRepository repository;
  const DeleteRecentSearchUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) =>
      repository.deleteRecentSearch(id);
}

class ClearRecentSearchesUseCase {
  final SearchRepository repository;
  const ClearRecentSearchesUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.clearRecentSearches();
}