import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load recent searches from the API on page open
class LoadRecentSearches extends SearchEvent {}

/// User typed in the search field
class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// User cleared the search field — go back to showing recent searches
class SearchCleared extends SearchEvent {}

/// User tapped a recent search pill — pre-fills and runs it immediately
class RecentSearchTapped extends SearchEvent {
  final String query;
  RecentSearchTapped(this.query);
  @override
  List<Object?> get props => [query];
}

/// User deleted one recent search entry (uses server id, not query string)
class RecentSearchDeleted extends SearchEvent {
  final String id;
  RecentSearchDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

/// User tapped "Clear all" recent searches
class RecentSearchesCleared extends SearchEvent {}

/// User tapped an area result — loads pros filtered by that area
class AreaSelected extends SearchEvent {
  final int areaId;
  final String areaName;
  final String city;
  final int proCount;
  AreaSelected({
    required this.areaId,
    required this.areaName,
    required this.city,
    required this.proCount,
  });
  @override
  List<Object?> get props => [areaId, areaName, city, proCount];
}

/// User tapped a category chip on the area results page
class AreaCategoryFilterChanged extends SearchEvent {
  final ServiceCategory? category;
  AreaCategoryFilterChanged(this.category);
  @override
  List<Object?> get props => [category];
}