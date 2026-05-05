import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/become_professional/domain/usecases/get_cities.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/service_pricing.dart';
import '../../domain/usecases/create_profile.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_service_areas.dart';
import '../../domain/usecases/get_services_for_category.dart';
import '../../domain/usecases/set_services.dart';
import '../../domain/usecases/submit_application.dart';
import '../../domain/usecases/upload_document.dart';
import '../../domain/usecases/upload_profile_picture.dart';
import 'become_professional_event.dart';
import 'become_professional_state.dart';

class BecomeProfessionalBloc
    extends Bloc<BecomeProfessionalEvent, BecomeProfessionalState> {
  static const Map<String, ({double lat, double lon})> _cityCoordinates = {
    'amman': (lat: 31.9454, lon: 35.9284),
    'irbid': (lat: 32.5569, lon: 35.7597),
    'zarqa': (lat: 32.0544, lon: 36.0998),
    'aqaba': (lat: 29.5290, lon: 35.0078),
  };

  static const Map<int, ({double lat, double lon})> _cityCoordinatesById = {
    1: (lat: 31.9454, lon: 35.9284),
    2: (lat: 32.5569, lon: 35.7597),
    3: (lat: 32.0544, lon: 36.0998),
    4: (lat: 29.5290, lon: 35.0078),
  };

  static const Map<String, ({double lat, double lon})> _areaOffsets = {
    'sweifieh': (lat: 0.0200, lon: 0.0300),
    'khalda': (lat: 0.0150, lon: -0.0200),
    'alrabiah': (lat: -0.0100, lon: 0.0250),
    'rabieh': (lat: -0.0100, lon: 0.0250),
    'rabiah': (lat: -0.0100, lon: 0.0250),
  };

  final GetCategories getCategories;
  final GetServiceAreas getServiceAreas;
  final GetServicesForCategory getServicesForCategory;
  final CreateProfile createProfile;
  final SetServices setServices;
  final UploadProfilePicture uploadProfilePicture;
  final UploadDocument uploadDocument;
  final SubmitApplication submitApplication;
  final GetCitiesFromProfessional getCitiesFromProfessional;

  BecomeProfessionalBloc({
    required this.getCategories,
    required this.getServiceAreas,
    required this.getServicesForCategory,
    required this.createProfile,
    required this.setServices,
    required this.uploadProfilePicture,
    required this.uploadDocument,
    required this.submitApplication,
    required this.getCitiesFromProfessional,
  }) : super(const BecomeProfessionalState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadServicesForCategory>(_onLoadServicesForCategory);

    on<CategorySelected>(_onCategorySelected);
    on<ExperienceYearsSelected>(_onExperienceYearsSelected);
    on<CitySelected>(_onCitySelected);
    on<ServiceAreaSelected>(_onServiceAreaSelected);
    on<BioChanged>(_onBioChanged);
    on<SubmitStep1>(_onSubmitStep1);

    on<ServiceAdded>(_onServiceAdded);
    on<ServiceRemoved>(_onServiceRemoved);
    on<SubmitStep2>(_onSubmitStep2);

    on<ProfilePicturePicked>(_onProfilePicturePicked);
    on<DocumentPicked>(_onDocumentPicked);
    on<UploadProfilePictureRequested>(_onUploadProfilePicture);
    on<UploadDocumentRequested>(_onUploadDocument);
    on<SubmitApplicationRequested>(_onSubmitApplication);
  }

  // ── Lookups ───────────────────────────────────────────────────────────────

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    emit(state.copyWith(initialDataStatus: ActionStatus.loading));

    final categoriesResult = await getCategories();
    final areasResult = await getServiceAreas();
    final citiesResult = await getCitiesFromProfessional();

    String? error;
    var newState = state;

    categoriesResult.fold(
      (failure) => error = failure.message,
      (categories) {
        newState = newState.copyWith(categories: categories);
      },
    );

    areasResult.fold(
      (failure) => error ??= failure.message,
      (areas) {
        newState = newState.copyWith(serviceAreas: areas);
      },
    );

    citiesResult.fold(
      (failure) => error ??= failure.message,
      (cities) {
        newState = newState.copyWith(cities: cities);
      },
    );

    if (error != null) {
      emit(newState.copyWith(
        initialDataStatus: ActionStatus.failure,
        errorMessage: error,
      ));
    } else {
      emit(newState.copyWith(initialDataStatus: ActionStatus.success));
    }
  }

  Future<void> _onLoadServicesForCategory(
    LoadServicesForCategory event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    emit(state.copyWith(
      categoryServicesStatus: ActionStatus.loading,
      categoryServices: const [],
    ));
    final result = await getServicesForCategory(event.categoryId);
    result.fold(
      (failure) => emit(state.copyWith(
        categoryServicesStatus: ActionStatus.failure,
        errorMessage: failure.message,
      )),
      (services) => emit(state.copyWith(
        categoryServicesStatus: ActionStatus.success,
        categoryServices: services,
      )),
    );
  }

  // ── Step 1 field updates ──────────────────────────────────────────────────

  void _onCategorySelected(
    CategorySelected event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(
        categoryId: event.categoryId,
        categoryName: event.categoryName,
        services: const [],
      ),
      categoryServices: const [],
    ));
    add(LoadServicesForCategory(event.categoryId));
  }

  void _onExperienceYearsSelected(
    ExperienceYearsSelected event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(
        experienceYears: event.years,
      ),
    ));
  }

  void _onCitySelected(
    CitySelected event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(
        cityId: event.cityId,
        cityName: event.cityName,
        serviceAreaId: 0,
        serviceAreaName: '',
      ),
    ));
  }

  void _onServiceAreaSelected(
    ServiceAreaSelected event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(
        serviceAreaId: event.serviceAreaId,
        serviceAreaName: event.serviceAreaName,
      ),
    ));
  }

  void _onBioChanged(
    BioChanged event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(bio: event.bio),
    ));
  }

  Future<void> _onSubmitStep1(
    SubmitStep1 event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    final app = state.application;
    if (!app.isStep1Valid) {
      emit(state.copyWith(
        step1Status: ActionStatus.failure,
        errorMessage: 'Please fill in all fields.',
      ));
      return;
    }

    final coordinates = _coordinatesFor(
      cityId: app.cityId,
      cityName: app.cityName,
      areaName: app.serviceAreaName,
    );

    emit(state.copyWith(step1Status: ActionStatus.loading, clearError: true));
    final result = await createProfile(
      categoryId: app.categoryId!,
      experienceYears: app.experienceYears!,
      serviceAreaId: (app.serviceAreaId ?? 0) > 0 ? app.serviceAreaId : null,
      latitude: coordinates?.lat,
      longitude: coordinates?.lon,
      bio: app.bio.trim(),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        step1Status: ActionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(step1Status: ActionStatus.success)),
    );
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────

  void _onServiceAdded(
    ServiceAdded event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final updated = List<ServicePricing>.from(state.application.services)
      ..removeWhere((s) => s.serviceId == event.service.serviceId)
      ..add(event.service);
    emit(state.copyWith(
      application: state.application.copyWith(services: updated),
    ));
  }

  void _onServiceRemoved(
    ServiceRemoved event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final updated = state.application.services
        .where((s) => s.serviceId != event.serviceId)
        .toList();
    emit(state.copyWith(
      application: state.application.copyWith(services: updated),
    ));
  }

  Future<void> _onSubmitStep2(
    SubmitStep2 event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    if (!state.application.isStep2Valid) {
      emit(state.copyWith(
        step2Status: ActionStatus.failure,
        errorMessage: 'Please add at least one service.',
      ));
      return;
    }

    emit(state.copyWith(step2Status: ActionStatus.loading, clearError: true));
    final result = await setServices(state.application.services);
    result.fold(
      (failure) => emit(state.copyWith(
        step2Status: ActionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(step2Status: ActionStatus.success)),
    );
  }

  // ── Step 3 ────────────────────────────────────────────────────────────────

  void _onProfilePicturePicked(
    ProfilePicturePicked event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(
        profileImagePath: event.filePath,
      ),
      profilePictureUploadStatus: ActionStatus.idle,
    ));
  }

  void _onDocumentPicked(
    DocumentPicked event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final app = state.application;
    final updatedApp = switch (event.documentType) {
      DocumentType.identity =>
        app.copyWith(identityPath: event.filePath),
      DocumentType.certification =>
        app.copyWith(certificationPath: event.filePath),
      DocumentType.goodConduct =>
        app.copyWith(goodConductPath: event.filePath),
    };

    final newDocStatus = Map<DocumentType, ActionStatus>.from(
      state.documentUploadStatus,
    )..[event.documentType] = ActionStatus.idle;

    emit(state.copyWith(
      application: updatedApp,
      documentUploadStatus: newDocStatus,
    ));
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePictureRequested event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    final path = state.application.profileImagePath;
    if (path == null) {
      emit(state.copyWith(
        profilePictureUploadStatus: ActionStatus.failure,
        errorMessage: 'Please choose a photo first.',
      ));
      return;
    }

    emit(state.copyWith(
      profilePictureUploadStatus: ActionStatus.loading,
      clearError: true,
    ));
    final result = await uploadProfilePicture(path);
    result.fold(
      (failure) => emit(state.copyWith(
        profilePictureUploadStatus: ActionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        profilePictureUploadStatus: ActionStatus.success,
      )),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocumentRequested event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    final path = state.application.pathFor(event.documentType);
    if (path == null) {
      _setDocStatus(emit, event.documentType, ActionStatus.failure,
          error: 'Please choose a file first.');
      return;
    }

    _setDocStatus(emit, event.documentType, ActionStatus.loading,
        clearError: true);

    final result = await uploadDocument(
      filePath: path,
      documentType: event.documentType,
    );
    result.fold(
      (failure) => _setDocStatus(
        emit,
        event.documentType,
        ActionStatus.failure,
        error: failure.message,
      ),
      (_) => _setDocStatus(emit, event.documentType, ActionStatus.success),
    );
  }

  void _setDocStatus(
    Emitter<BecomeProfessionalState> emit,
    DocumentType type,
    ActionStatus status, {
    String? error,
    bool clearError = false,
  }) {
    final newMap = Map<DocumentType, ActionStatus>.from(
      state.documentUploadStatus,
    )..[type] = status;
    emit(state.copyWith(
      documentUploadStatus: newMap,
      errorMessage: error,
      clearError: clearError,
    ));
  }

  // ── Final submit ──────────────────────────────────────────────────────────

  Future<void> _onSubmitApplication(
    SubmitApplicationRequested event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    if (!state.application.isStep3Valid) {
      emit(state.copyWith(
        submitStatus: ActionStatus.failure,
        errorMessage:
            'Please upload a profile picture and your ID before submitting.',
      ));
      return;
    }

    emit(state.copyWith(submitStatus: ActionStatus.loading, clearError: true));
    final result = await submitApplication();
    result.fold(
      (failure) => emit(state.copyWith(
        submitStatus: ActionStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(submitStatus: ActionStatus.success)),
    );
  }

  ({double lat, double lon})? _coordinatesFor({
    int? cityId,
    String? cityName,
    String? areaName,
  }) {
    final cityCenter = cityId != null ? _cityCoordinatesById[cityId] : null;
    final normalizedCity = cityCenter == null ? _normalizeLocationKey(cityName) : null;
    final resolvedCity = cityCenter ??
        (normalizedCity == null ? null : _cityCoordinates[normalizedCity]);

    if (resolvedCity == null) return null;

    final normalizedArea = _normalizeLocationKey(areaName);
    final offset = normalizedArea == null ? null : _areaOffsets[normalizedArea];
    return (
      lat: resolvedCity.lat + (offset?.lat ?? 0),
      lon: resolvedCity.lon + (offset?.lon ?? 0),
    );
  }

  String? _normalizeLocationKey(String? raw) {
    if (raw == null) return null;
    final normalized = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.isEmpty ? null : normalized;
  }
}