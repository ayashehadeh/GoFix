import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/favorites/favorites_cache.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/usecases/favorites_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

class AddFavoriteEvent extends FavoritesEvent {
  final FavoriteEntity favorite;
  const AddFavoriteEvent(this.favorite);
  @override
  List<Object?> get props => [favorite];
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final String professionalId;
  const RemoveFavoriteEvent(this.professionalId);
  @override
  List<Object?> get props => [professionalId];
}

class ToggleFavoriteFromCardEvent extends FavoritesEvent {
  final FavoriteEntity favorite;
  const ToggleFavoriteFromCardEvent(this.favorite);
  @override
  List<Object?> get props => [favorite];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteEntity> favorites;
  const FavoritesLoaded(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesList getFavoritesList;
  final AddFavorite addFavorite;
  final RemoveFavorite removeFavorite;
  final IsFavorite isFavorite;

  FavoritesBloc({
    required this.getFavoritesList,
    required this.addFavorite,
    required this.removeFavorite,
    required this.isFavorite,
  }) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoad);
    on<AddFavoriteEvent>(_onAdd);
    on<RemoveFavoriteEvent>(_onRemove);
    on<ToggleFavoriteFromCardEvent>(_onToggleFromCard);
  }

  Future<void> _onLoad(
      LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await getFavoritesList();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) {
        FavoritesCache.instance.setAll(favorites.map((f) => f.id));
        emit(FavoritesLoaded(favorites));
      },
    );
  }

  Future<void> _onAdd(
      AddFavoriteEvent event, Emitter<FavoritesState> emit) async {
    await addFavorite(event.favorite);
    final result = await getFavoritesList();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) {
        FavoritesCache.instance.setAll(favorites.map((f) => f.id));
        emit(FavoritesLoaded(favorites));
      },
    );
  }

  Future<void> _onRemove(
      RemoveFavoriteEvent event, Emitter<FavoritesState> emit) async {
    FavoritesCache.instance.toggle(event.professionalId);
    if (state is FavoritesLoaded) {
      final current = state as FavoritesLoaded;
      final updated = current.favorites
          .where((f) => f.id != event.professionalId)
          .toList();
      emit(FavoritesLoaded(updated));
    }
    await removeFavorite(event.professionalId);
  }

  Future<void> _onToggleFromCard(ToggleFavoriteFromCardEvent event,
      Emitter<FavoritesState> emit) async {
    final isFavResult = await isFavorite(event.favorite.id);
    final currentlyFav = isFavResult.fold((_) => false, (r) => r);
    if (currentlyFav) {
      await removeFavorite(event.favorite.id);
    } else {
      await addFavorite(event.favorite);
    }
    final result = await getFavoritesList();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) {
        FavoritesCache.instance.setAll(favorites.map((f) => f.id));
        emit(FavoritesLoaded(favorites));
      },
    );
  }
}
