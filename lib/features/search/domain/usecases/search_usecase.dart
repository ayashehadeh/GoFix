import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;
  const SearchUseCase(this.repository);

  Future<Either<Failure, SearchResults>> call(String query) =>
      repository.search(query);
}
