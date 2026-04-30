import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/search/domain/usecases/get_professionals_by_area.dart';
import 'package:gp/features/search/domain/usecases/search_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase searchUseCase;
  final GetProfessionalsByArea getProfessionalsByArea;

  static const String _prefsKey = 'gofix_recent_searches';
  static const int _maxRecent = 8;

  // In-memory cache of recent searches for the session
  List<String> _recentSearches = [];

  // Remembered for category re-filter
  String? _selectedAreaName;
  String? _selectedAreaCity;
  int? _selectedAreaProCount;

  Timer? _debounce;

  SearchBloc({
    required this.searchUseCase,
    required this.getProfessionalsByArea,
  }) : super(SearchInitial()) {
    on<LoadRecentSearches>(_onLoadRecent);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
    on<RecentSearchTapped>(_onRecentTapped);
    on<RecentSearchDeleted>(_onRecentDeleted);
    on<RecentSearchesCleared>(_onRecentCleared);
    on<AreaSelected>(_onAreaSelected);
    on<AreaCategoryFilterChanged>(_onCategoryFilterChanged);
    on<_TriggerSearch>(_onTriggerSearch);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // ── Recent search persistence ──────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _recentSearches);
  }

  void _addToRecent(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _recentSearches.remove(q); // remove duplicate if exists
    _recentSearches.insert(0, q); // put at top
    if (_recentSearches.length > _maxRecent) {
      _recentSearches = _recentSearches.sublist(0, _maxRecent);
    }
    _saveToPrefs();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoadRecent(
    LoadRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    await _loadFromPrefs();
    emit(SearchInitial(recentSearches: List.from(_recentSearches)));
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    final query = event.query.trim();
    if (query.isEmpty) {
      _debounce?.cancel();
      emit(SearchInitial(recentSearches: List.from(_recentSearches)));
      return;
    }
    emit(SearchTyping(query, recentSearches: List.from(_recentSearches)));
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () { if (!isClosed) add(_TriggerSearch(query)); },
    );
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _debounce?.cancel();
    emit(SearchInitial(recentSearches: List.from(_recentSearches)));
  }

  Future<void> _onRecentTapped(
    RecentSearchTapped event,
    Emitter<SearchState> emit,
  ) async {
    // Treat exactly like typing + immediate search (no debounce)
    emit(SearchLoading(event.query));
    final result = await searchUseCase(event.query);
    result.fold(
      (failure) => emit(SearchError(failure.message,
          recentSearches: List.from(_recentSearches))),
      (results) {
        _addToRecent(event.query);
        emit(SearchLoaded(results));
      },
    );
  }

  void _onRecentDeleted(
    RecentSearchDeleted event,
    Emitter<SearchState> emit,
  ) {
    _recentSearches.remove(event.query);
    _saveToPrefs();
    emit(SearchInitial(recentSearches: List.from(_recentSearches)));
  }

  void _onRecentCleared(
    RecentSearchesCleared event,
    Emitter<SearchState> emit,
  ) {
    _recentSearches.clear();
    _saveToPrefs();
    emit(SearchInitial(recentSearches: const []));
  }

  Future<void> _onTriggerSearch(
    _TriggerSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(event.query));
    final result = await searchUseCase(event.query);
    result.fold(
      (failure) => emit(SearchError(failure.message,
          recentSearches: List.from(_recentSearches))),
      (results) {
        _addToRecent(event.query);
        emit(SearchLoaded(results));
      },
    );
  }

  Future<void> _onAreaSelected(
    AreaSelected event,
    Emitter<SearchState> emit,
  ) async {
    _selectedAreaName = event.areaName;
    _selectedAreaCity = event.city;
    _selectedAreaProCount = event.proCount;

    emit(AreaProfessionalsLoading(
      areaName: event.areaName,
      city: event.city,
      proCount: event.proCount,
    ));

    final result = await getProfessionalsByArea(areaName: event.areaName);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (pros) => emit(AreaProfessionalsLoaded(
        areaName: event.areaName,
        city: event.city,
        proCount: event.proCount,
        professionals: pros,
        activeCategory: null,
      )),
    );
  }

  Future<void> _onCategoryFilterChanged(
    AreaCategoryFilterChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (_selectedAreaName == null) return;
    final current = state;
    if (current is! AreaProfessionalsLoaded) return;

    emit(AreaProfessionalsLoading(
      areaName: current.areaName,
      city: current.city,
      proCount: current.proCount,
    ));

    final result = await getProfessionalsByArea(
      areaName: _selectedAreaName!,
      category: event.category,
    );
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (pros) => emit(AreaProfessionalsLoaded(
        areaName: _selectedAreaName!,
        city: _selectedAreaCity!,
        proCount: _selectedAreaProCount!,
        professionals: pros,
        activeCategory: event.category,
      )),
    );
  }
}

class _TriggerSearch extends SearchEvent {
  final String query;
  _TriggerSearch(this.query);
  @override
  List<Object?> get props => [query];
}
