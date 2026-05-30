import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/search/domain/repositories/search_repository.dart';
import 'package:gp/features/search/domain/usecases/search_usecase.dart'; // ← has ALL use cases
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase searchUseCase;
  final GetProfessionalsByArea getProfessionalsByArea;
  final GetRecentSearchesUseCase getRecentSearches;
  final RecordSearchUseCase recordSearch;
  final DeleteRecentSearchUseCase deleteRecentSearch;
  final ClearRecentSearchesUseCase clearRecentSearches;

  List<RecentSearch> _recentSearches = [];
  int? _selectedAreaId;
  String? _selectedAreaName;
  String? _selectedAreaNameAr;
  String? _selectedAreaCity;
  int? _selectedAreaProCount;
  Timer? _debounce;

  SearchBloc({
    required this.searchUseCase,
    required this.getProfessionalsByArea,
    required this.getRecentSearches,
    required this.recordSearch,
    required this.deleteRecentSearch,
    required this.clearRecentSearches,
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

  List<String> get _labels => _recentSearches.map((r) => r.query).toList();

  SearchInitial get _initialState => SearchInitial(
        recentSearches: _labels,
        recentSearchObjects: List.from(_recentSearches),
      );

  Future<void> _onLoadRecent(
    LoadRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    final result = await getRecentSearches();
    result.fold(
      (_) => emit(SearchInitial()),
      (list) {
        _recentSearches = list;
        emit(_initialState);
      },
    );
  }

  Future<void> _onRecentDeleted(
    RecentSearchDeleted event,
    Emitter<SearchState> emit,
  ) async {
    _recentSearches.removeWhere((r) => r.id == event.id);
    emit(_initialState);
    await deleteRecentSearch(event.id);
  }

  Future<void> _onRecentCleared(
    RecentSearchesCleared event,
    Emitter<SearchState> emit,
  ) async {
    _recentSearches = [];
    emit(SearchInitial());
    await clearRecentSearches();
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    final query = event.query.trim();
    if (query.isEmpty) {
      _debounce?.cancel();
      emit(_initialState);
      return;
    }
    emit(SearchTyping(query, recentSearches: _labels));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!isClosed) add(_TriggerSearch(query));
    });
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _debounce?.cancel();
    emit(_initialState);
  }

  Future<void> _onRecentTapped(
    RecentSearchTapped event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(event.query));
    final result = await searchUseCase(event.query);
    result.fold(
      (failure) =>
          emit(SearchError(failure.message, recentSearches: _labels)),
      (results) => emit(SearchLoaded(results)),
    );
    await recordSearch(event.query);
    await _refreshRecents();
  }

  Future<void> _onTriggerSearch(
    _TriggerSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading(event.query));
    final result = await searchUseCase(event.query);
    result.fold(
      (failure) =>
          emit(SearchError(failure.message, recentSearches: _labels)),
      (results) => emit(SearchLoaded(results)),
    );
    await recordSearch(event.query);
    await _refreshRecents();
  }

  Future<void> _refreshRecents() async {
    final result = await getRecentSearches();
    result.fold((_) => null, (list) => _recentSearches = list);
  }

  Future<void> _onAreaSelected(
    AreaSelected event,
    Emitter<SearchState> emit,
  ) async {
    _selectedAreaId = event.areaId;
    _selectedAreaName = event.areaName;
    _selectedAreaNameAr = event.areaNameAr;
    _selectedAreaCity = event.city;
    _selectedAreaProCount = event.proCount;

    emit(AreaProfessionalsLoading(
      areaName: event.areaName,
      areaNameAr: event.areaNameAr,
      city: event.city,
      proCount: event.proCount,
    ));

    final result = await getProfessionalsByArea(areaId: event.areaId);
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (pros) => emit(AreaProfessionalsLoaded(
        areaName: event.areaName,
        areaNameAr: event.areaNameAr,
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
    if (_selectedAreaId == null) return;
    final current = state;
    if (current is! AreaProfessionalsLoaded) return;

    emit(AreaProfessionalsLoading(
      areaName: current.areaName,
      areaNameAr: current.areaNameAr,
      city: current.city,
      proCount: current.proCount,
    ));

    final result = await getProfessionalsByArea(
      areaId: _selectedAreaId!,
      category: event.category,
    );
    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (pros) => emit(AreaProfessionalsLoaded(
        areaName: _selectedAreaName!,
        areaNameAr: _selectedAreaNameAr,
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