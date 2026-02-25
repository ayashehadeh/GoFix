import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gp/features/home/domain/use_cases/get_categories_usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../../../core/error/failures.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {}

class HomeRefreshRequested extends HomeEvent {}

// ─── States ────────────────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final String locationName;

  HomeLoaded({required this.categories, required this.locationName});

  @override
  List<Object?> get props => [categories, locationName];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Bloc ──────────────────────────────────────────────────────────────────

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategoriesUseCase getCategoriesUseCase;

  HomeBloc({required this.getCategoriesUseCase}) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onRefresh);
  }
  //handles event 1
  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await _fetchData(emit);
  }
  //handles event 2
  Future<void> _onRefresh(HomeRefreshRequested event, Emitter<HomeState> emit) async {
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<HomeState> emit) async {
    // Run separately so types are preserved
    final String locationName = await _getLocationName();
    final Either<Failure, List<CategoryEntity>> categoriesResult = await getCategoriesUseCase();//calls the usecase.

    categoriesResult.fold(
      (failure) => emit(HomeError(failure.message)),
      (categories) => emit(HomeLoaded(
        categories: categories,
        locationName: locationName,
      )),
    );
  }

  Future<String> _getLocationName() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 'Permission denied';
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Permission denied';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return 'Unknown location';

      final place = placemarks.first;
      final parts = [place.subLocality, place.locality]
          .where((p) => p != null && p.isNotEmpty)
          .toList();

      if (parts.isEmpty) return place.country ?? 'Unknown location';
      return parts.join(', ');
    } catch (_) {
      return 'Amman, Jordan';
    }
  }
}