import 'package:equatable/equatable.dart';
import 'package:gp/core/error/app_error_state.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';
import 'package:gp/features/search/domain/repositories/search_repository.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Empty field — shows recent searches (may be an empty list)
class SearchInitial extends SearchState {
  /// Display labels (query strings) — kept for backward compat
  final List<String> recentSearches;

  /// Full objects with server id — used by search_page for id-based deletion
  final List<RecentSearch> recentSearchObjects;

  SearchInitial({
    this.recentSearches = const [],
    this.recentSearchObjects = const [],
  });

  @override
  List<Object?> get props => [recentSearches, recentSearchObjects];
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
  final String? areaNameAr;
  final String city;
  final int proCount;
  AreaProfessionalsLoading({
    required this.areaName,
    this.areaNameAr,
    required this.city,
    required this.proCount,
  });
  @override
  List<Object?> get props => [areaName, areaNameAr, city, proCount];
}

/// Area professionals loaded
class AreaProfessionalsLoaded extends SearchState {
  final String areaName;
  final String? areaNameAr;
  final String city;
  final int proCount;
  final List<Professional> professionals;
  final ServiceCategory? activeCategory;

  AreaProfessionalsLoaded({
    required this.areaName,
    this.areaNameAr,
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
      areaNameAr: areaNameAr,
      city: city,
      proCount: proCount,
      professionals: professionals ?? this.professionals,
      activeCategory:
          clearCategory ? null : (activeCategory ?? this.activeCategory),
    );
  }

  @override
  List<Object?> get props =>
      [areaName, areaNameAr, city, proCount, professionals, activeCategory];
}

class SearchError extends SearchState with AppErrorState {
  final String message;
  final List<String> recentSearches;
  SearchError(this.message, {this.recentSearches = const []});
  @override
  List<Object?> get props => [message, recentSearches];
}