import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Empty field — shows recent searches (may be an empty list)
class SearchInitial extends SearchState {
  final List<String> recentSearches;
  SearchInitial({this.recentSearches = const []});
  @override
  List<Object?> get props => [recentSearches];
}

/// Typing but waiting for debounce
class SearchTyping extends SearchState {
  final String query;
  final List<String> recentSearches;
  SearchTyping(this.query, {this.recentSearches = const []});
  @override
  List<Object?> get props => [query, recentSearches];
}

/// API call in flight
class SearchLoading extends SearchState {
  final String query;
  SearchLoading(this.query);
  @override
  List<Object?> get props => [query];
}

/// Results returned — could be empty
class SearchLoaded extends SearchState {
  final SearchResults results;
  SearchLoaded(this.results);
  @override
  List<Object?> get props => [results];
}

/// User tapped an area — loading pros for that area
class AreaProfessionalsLoading extends SearchState {
  final String areaName;
  final String city;
  final int proCount;
  AreaProfessionalsLoading({
    required this.areaName,
    required this.city,
    required this.proCount,
  });
  @override
  List<Object?> get props => [areaName, city, proCount];
}

/// Area professionals loaded
class AreaProfessionalsLoaded extends SearchState {
  final String areaName;
  final String city;
  final int proCount;
  final List<Professional> professionals;
  final ServiceCategory? activeCategory;

  AreaProfessionalsLoaded({
    required this.areaName,
    required this.city,
    required this.proCount,
    required this.professionals,
    this.activeCategory,
  });

  AreaProfessionalsLoaded copyWith({
    List<Professional>? professionals,
    ServiceCategory? activeCategory,
    bool clearCategory = false,
  }) {
    return AreaProfessionalsLoaded(
      areaName: areaName,
      city: city,
      proCount: proCount,
      professionals: professionals ?? this.professionals,
      activeCategory:
          clearCategory ? null : (activeCategory ?? this.activeCategory),
    );
  }

  @override
  List<Object?> get props =>
      [areaName, city, proCount, professionals, activeCategory];
}

class SearchError extends SearchState {
  final String message;
  final List<String> recentSearches;
  SearchError(this.message, {this.recentSearches = const []});
  @override
  List<Object?> get props => [message, recentSearches];
}
