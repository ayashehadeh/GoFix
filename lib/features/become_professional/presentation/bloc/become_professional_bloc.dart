import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/become_professional/domain/usecases/get_cities.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/service_pricing.dart';
import '../../domain/usecases/create_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_service_areas.dart';
import '../../domain/usecases/get_services_for_category.dart';
import '../../domain/usecases/set_service_areas.dart';
import '../../domain/usecases/set_services.dart';
import '../../domain/usecases/submit_application.dart';
import '../../domain/usecases/upload_document.dart';
import '../../domain/usecases/upload_profile_picture.dart';
import 'become_professional_event.dart';
import 'become_professional_state.dart';

class BecomeProfessionalBloc extends Bloc<BecomeProfessionalEvent, BecomeProfessionalState> {
  static const Map<int, ({double lat, double lon})> _cityCoordinatesById = {
    1: (lat: 31.9454, lon: 35.9284), // Amman
    2: (lat: 32.5569, lon: 35.7597), // Irbid
    3: (lat: 32.0544, lon: 36.0998), // Zarqa
    4: (lat: 29.5290, lon: 35.0078), // Aqaba
  };

  final GetCategories getCategories;
  final GetServiceAreas getServiceAreas;
  final GetServicesForCategory getServicesForCategory;
  final CreateProfile createProfile;
  final UpdateProfile updateProfile;
  final SetServices setServices;
  final SetServiceAreas setServiceAreas;
  final UploadProfilePicture uploadProfilePicture;
  final UploadDocument uploadDocument;
  final SubmitApplication submitApplication;
  final GetCitiesFromProfessional getCitiesFromProfessional;

  /// True when the bloc is being used by the Edit Profile wizard
  /// (set in _onPreloadProfileData, which only runs in edit mode).
  bool _isEditMode = false;

  BecomeProfessionalBloc({
    required this.getCategories,
    required this.getServiceAreas,
    required this.getServicesForCategory,
    required this.createProfile,
    required this.updateProfile,
    required this.setServices,
    required this.setServiceAreas,
    required this.uploadProfilePicture,
    required this.uploadDocument,
    required this.submitApplication,
    required this.getCitiesFromProfessional,
  }) : super(const BecomeProfessionalState()) {
    on<PreloadProfileData>(_onPreloadProfileData);
    on<LoadInitialData>(_onLoadInitialData);
    on<LoadServicesForCategory>(_onLoadServicesForCategory);

    on<CategorySelected>(_onCategorySelected);
    on<ExperienceYearsSelected>(_onExperienceYearsSelected);
    on<CitySelected>(_onCitySelected);
    on<ServiceAreaToggled>(_onServiceAreaToggled);
    on<BioChanged>(_onBioChanged);
    on<SubmitStep1>(_onSubmitStep1);

    on<ServiceAdded>(_onServiceAdded);
    on<ServiceRemoved>(_onServiceRemoved);
    on<SubmitStep2>(_onSubmitStep2);

    on<ProfilePicturePicked>(_onProfilePicturePicked);
    on<DocumentPicked>(_onDocumentPicked);
    // ↓ New path-carrying events — no race condition
    on<UploadProfilePictureWithPathRequested>(_onUploadProfilePicture);
    on<UploadDocumentWithPathRequested>(_onUploadDocument);
    on<SubmitApplicationRequested>(_onSubmitApplication);
  }

  // ── Edit profile pre-fill ─────────────────────────────────────────────────

  void _onPreloadProfileData(
    PreloadProfileData event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    _isEditMode = true;

    final p = event.professional;

    // Map ServiceCategory enum → integer id (mirrors backend _categoryId helper)
    final catId = _categoryIdFromEnum(p.category);

    // Map ServiceOffered → ServicePricing
    final services = p.services
        .map((s) => ServicePricing(
              serviceId: s.serviceId ?? 0,
              serviceName: s.name,
              minPrice: s.minPrice,
              maxPrice: s.maxPrice,
            ))
        .toList();

    // Derive cityId from first service area (areas carry their cityId)
    final cityId = p.serviceAreas.isNotEmpty ? p.serviceAreas.first.cityId : null;

    emit(state.copyWith(
      application: state.application.copyWith(
        categoryId: catId,
        categoryName: p.category.displayName,
        experienceYears: p.experienceYears,
        bio: p.bio,
        cityId: cityId != 0 ? cityId : null,
        selectedServiceAreaIds: p.serviceAreas.map((a) => a.id).toList(),
        selectedServiceAreaNames: p.serviceAreas.map((a) => a.name).toList(),
        services: services,
      ),
    ));

    // Trigger services list load for the category
    if (catId > 0) add(LoadServicesForCategory(catId));
  }

  static int _categoryIdFromEnum(dynamic category) {
    try {
      // ignore: avoid_dynamic_calls
      return (category as dynamic).index + 1;
    } catch (_) {
      return 1;
    }
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
      (f) => error = f.message,
      (cats) => newState = newState.copyWith(categories: cats),
    );
    areasResult.fold(
      (f) => error ??= f.message,
      (areas) => newState = newState.copyWith(serviceAreas: areas),
    );
    citiesResult.fold(
      (f) => error ??= f.message,
      (cities) => newState = newState.copyWith(cities: cities),
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
      (f) => emit(state.copyWith(
        categoryServicesStatus: ActionStatus.failure,
        errorMessage: f.message,
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
      application: state.application.copyWith(experienceYears: event.years),
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
        selectedServiceAreaIds: const [],
        selectedServiceAreaNames: const [],
      ),
    ));
  }

  void _onServiceAreaToggled(
    ServiceAreaToggled event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final ids = List<int>.from(state.application.selectedServiceAreaIds);
    final names = List<String>.from(state.application.selectedServiceAreaNames);

    if (ids.contains(event.serviceAreaId)) {
      final idx = ids.indexOf(event.serviceAreaId);
      ids.removeAt(idx);
      names.removeAt(idx);
    } else {
      ids.add(event.serviceAreaId);
      names.add(event.serviceAreaName);
    }

    emit(state.copyWith(
      application: state.application.copyWith(
        selectedServiceAreaIds: ids,
        selectedServiceAreaNames: names,
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
        errorMessage: 'Please fill in all required fields.',
      ));
      return;
    }

    final coords = app.cityId != null ? _cityCoordinatesById[app.cityId] : null;

    emit(state.copyWith(step1Status: ActionStatus.loading, clearError: true));

    final profileResult = _isEditMode
        ? await updateProfile(
            categoryId: app.categoryId!,
            experienceYears: app.experienceYears!,
            latitude: coords?.lat,
            longitude: coords?.lon,
            bio: app.bio.trim(),
          )
        : await createProfile(
            categoryId: app.categoryId!,
            experienceYears: app.experienceYears!,
            latitude: coords?.lat,
            longitude: coords?.lon,
            bio: app.bio.trim(),
          );

    if (profileResult.isLeft()) {
      profileResult.fold(
        (f) => emit(state.copyWith(
          step1Status: ActionStatus.failure,
          errorMessage: f.message,
        )),
        (_) => null,
      );
      return;
    }

    final areasResult = await setServiceAreas(app.selectedServiceAreaIds);

    areasResult.fold(
      (f) => emit(state.copyWith(
        step1Status: ActionStatus.failure,
        errorMessage: f.message,
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
    final updated = state.application.services.where((s) => s.serviceId != event.serviceId).toList();
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
      (f) => emit(state.copyWith(
        step2Status: ActionStatus.failure,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(step2Status: ActionStatus.success)),
    );
  }

  // ── Step 3 – Documents ────────────────────────────────────────────────────

  void _onProfilePicturePicked(
    ProfilePicturePicked event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    emit(state.copyWith(
      application: state.application.copyWith(profileImagePath: event.filePath),
      profilePictureUploadStatus: ActionStatus.idle,
    ));
  }

  void _onDocumentPicked(
    DocumentPicked event,
    Emitter<BecomeProfessionalState> emit,
  ) {
    final app = state.application;
    final updatedApp = switch (event.documentType) {
      DocumentType.identity => app.copyWith(identityPath: event.filePath),
      DocumentType.certification => app.copyWith(certificationPath: event.filePath),
      DocumentType.goodConduct => app.copyWith(goodConductPath: event.filePath),
    };
    final newDocStatus = Map<DocumentType, ActionStatus>.from(state.documentUploadStatus)
      ..[event.documentType] = ActionStatus.idle;
    emit(state.copyWith(
      application: updatedApp,
      documentUploadStatus: newDocStatus,
    ));
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePictureWithPathRequested event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    emit(state.copyWith(
      profilePictureUploadStatus: ActionStatus.loading,
      clearError: true,
    ));
    final result = await uploadProfilePicture(event.filePath);
    result.fold(
      (f) => emit(state.copyWith(
        profilePictureUploadStatus: ActionStatus.failure,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(profilePictureUploadStatus: ActionStatus.success)),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocumentWithPathRequested event,
    Emitter<BecomeProfessionalState> emit,
  ) async {
    _setDocStatus(emit, event.documentType, ActionStatus.loading, clearError: true);
    final result = await uploadDocument(
      filePath: event.filePath,
      documentType: event.documentType,
    );
    result.fold(
      (f) => _setDocStatus(emit, event.documentType, ActionStatus.failure, error: f.message),
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
    final newMap = Map<DocumentType, ActionStatus>.from(state.documentUploadStatus)..[type] = status;
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
    if (!state.application.isStep4Valid) {
      emit(state.copyWith(
        submitStatus: ActionStatus.failure,
        errorMessage: 'Please upload a profile picture and your ID before submitting.',
      ));
      return;
    }
    emit(state.copyWith(submitStatus: ActionStatus.loading, clearError: true));
    final result = await submitApplication();
    result.fold(
      (f) => emit(state.copyWith(
        submitStatus: ActionStatus.failure,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(submitStatus: ActionStatus.success)),
    );
  }
}
