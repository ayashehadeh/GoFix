import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';
import 'package:gp/features/search/domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  const SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SearchResults>> search(String query) async {
    try {
      final professionals = await remoteDataSource.searchProfessionals(query);
      final areas = await remoteDataSource.searchAreas(query);
      final services = await remoteDataSource.searchServices(query);
      return Right(SearchResults(
        professionals: professionals,
        areas: areas,
        services: services,
        query: query,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> getProfessionalsByArea({
    required int areaId,
    ServiceCategory? category,
  }) async {
    try {
      final result = await remoteDataSource.getProfessionalsByArea(
        areaId: areaId,
        category: category,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Recent searches ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<RecentSearch>>> getRecentSearches() async {
    try {
      final result = await remoteDataSource.getRecentSearches();
      return Right(result
          .map((m) => RecentSearch(id: m.id, query: m.query))
          .toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordSearch(String query) async {
    try {
      await remoteDataSource.recordSearch(query);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecentSearch(String id) async {
    try {
      await remoteDataSource.deleteRecentSearch(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentSearches() async {
    try {
      await remoteDataSource.clearRecentSearches();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}