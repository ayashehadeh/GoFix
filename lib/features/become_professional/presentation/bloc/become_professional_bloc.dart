import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professionals/domain/entities/city.dart';
import 'package:gp/features/professionals/domain/entities/service_area.dart';
import 'package:gp/features/professionals/domain/entities/service_offered.dart';
import 'package:gp/features/professionals/domain/repositories/professionals_repository.dart';
import '../../domain/usecases/submit_professional_application.dart';
import 'become_professional_event.dart';
import 'become_professional_state.dart';

class BecomeProfessionalBloc
    extends Bloc<BecomeProfessionalEvent, BecomeProfessionalState> {
  final SubmitProfessionalApplication submitApplicationUseCase;
  final ProfessionalsRepository professionalsRepository;

  // Cached so pages can read without triggering rebuilds
  List<City> _cities = [];
  List<ServiceArea> _areas = [];
  List<ServiceOffered> _categoryServices = [];

  List<City> get cachedCities => _cities;
  List<ServiceArea> get cachedAreas => _areas;
  List<ServiceOffered> get cachedCategoryServices => _categoryServices;

  BecomeProfessionalBloc({
    required this.submitApplicationUseCase,
    required this.professionalsRepository,
  }) : super(BecomeProfessionalFormState()) {
    on<LoadCities>(_onLoadCities);
    on<LoadAreas>(_onLoadAreas);
    on<LoadServicesForCategory>(_onLoadServicesForCategory);
    on<UpdateStep1>(_onUpdateStep1);
    on<UpdateServices>(_onUpdateServices);
    on<UpdateDocument>(_onUpdateDocument);
    on<SubmitApplication>(_onSubmit);
  }

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    final saved = _formState;
    emit(CitiesLoading());
    final result = await professionalsRepository.getCities();
    result.fold(
      (failure) {
        emit(BecomeProfessionalError(failure.message));
        emit(saved);
      },
      (cities) {
        _cities = cities;
        emit(CitiesLoaded(cities));
        emit(saved);
      },
    );
  }

  Future<void> _onLoadAreas(
    LoadAreas event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    final saved = _formState;
    emit(AreasLoading());
    final result =
        await professionalsRepository.getServiceAreas(cityId: event.cityId);
    result.fold(
      (failure) {
        emit(BecomeProfessionalError(failure.message));
        emit(saved);
      },
      (areas) {
        _areas = areas;
        emit(AreasLoaded(areas));
        emit(saved);
      },
    );
  }

  Future<void> _onLoadServicesForCategory(
    LoadServicesForCategory event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    final saved = _formState;
    emit(CategoryServicesLoading());
    // TODO: Implement getServicesByCategory in ProfessionalsRepository once backend endpoint is available
    // For now, emit empty list
    _categoryServices = [];
    emit(CategoryServicesLoaded([]));
    emit(saved);
  }

  // ── Form updates ──────────────────────────────────────────────────────────

  void _onUpdateStep1(
    UpdateStep1 event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(_formState.copyWith(
      serviceCategory: event.serviceCategory,
      categoryId: event.categoryId,
      experienceLevel: event.experienceLevel,
      workDescription: event.workDescription,
      cityId: event.cityId,
      serviceAreaId: event.serviceAreaId,
    ));
  }

  void _onUpdateServices(
    UpdateServices event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(_formState.copyWith(services: event.services));
  }

  void _onUpdateDocument(
    UpdateDocument event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final current = _formState;
    switch (event.type) {
      case DocumentType.profile:
        emit(current.copyWith(profileImagePath: event.path));
        break;
      case DocumentType.id:
        emit(current.copyWith(idImagePath: event.path));
        break;
      case DocumentType.certification:
        emit(current.copyWith(certificationImagePath: event.path));
        break;
      case DocumentType.conduct:
        emit(current.copyWith(conductImagePath: event.path));
        break;
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
    SubmitApplication event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    emit(BecomeProfessionalSubmitting());
    final result = await submitApplicationUseCase(_formState.toEntity());
    result.fold(
      (failure) => emit(BecomeProfessionalError(failure.message)),
      (_) => emit(BecomeProfessionalSuccess()),
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  BecomeProfessionalFormState get _formState {
    final s = state;
    return s is BecomeProfessionalFormState ? s : BecomeProfessionalFormState();
  }
}
