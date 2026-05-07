import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_service.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/professional_application.dart';
import '../../domain/entities/service_area.dart';

enum ActionStatus { idle, loading, success, failure }

class BecomeProfessionalState extends Equatable {
  // ── Lookups ─────────────────────────────────────────────────────────────
  final ActionStatus initialDataStatus;
  final List<Category> categories;
  final List<City> cities;
  final List<ServiceArea> serviceAreas;
  final ActionStatus categoryServicesStatus;
  final List<CategoryService> categoryServices;

  // ── Application data ────────────────────────────────────────────────────
  final ProfessionalApplication application;

  // ── Per-action statuses ─────────────────────────────────────────────────
  final ActionStatus step1Status;
  final ActionStatus step2Status;
  final ActionStatus profilePictureUploadStatus;
  final Map<DocumentType, ActionStatus> documentUploadStatus;
  final ActionStatus submitStatus;

  final String? errorMessage;

  const BecomeProfessionalState({
    this.initialDataStatus = ActionStatus.idle,
    this.categories = const [],
    this.cities = const [],
    this.serviceAreas = const [],
    this.categoryServicesStatus = ActionStatus.idle,
    this.categoryServices = const [],
    this.application = const ProfessionalApplication(),
    this.step1Status = ActionStatus.idle,
    this.step2Status = ActionStatus.idle,
    this.profilePictureUploadStatus = ActionStatus.idle,
    this.documentUploadStatus = const {},
    this.submitStatus = ActionStatus.idle,
    this.errorMessage,
  });

  /// Areas filtered to the currently-selected city.
  List<ServiceArea> get areasForSelectedCity {
    final cityId = application.cityId;
    if (cityId == null) return const [];
    return serviceAreas.where((a) => a.cityId == cityId).toList();
  }

  /// All areas — used as fallback when no city is selected.
  List<ServiceArea> get allAreas => serviceAreas;

  /// Cities from API if available, otherwise derived from service areas.
  List<({int id, String name})> get derivedCities {
    if (cities.isNotEmpty) {
      return cities
          .map((c) => (id: c.id, name: c.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    final seen = <int>{};
    final result = <({int id, String name})>[];
    for (final area in serviceAreas) {
      if (area.cityId == 0) continue;
      if (seen.add(area.cityId)) {
        result.add((id: area.cityId, name: _mapCityIdToName(area.cityId)));
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  String _mapCityIdToName(int cityId) {
    const cityMap = {1: 'Amman', 2: 'Irbid', 3: 'Zarqa', 4: 'Aqaba'};
    return cityMap[cityId] ?? 'City $cityId';
  }

  ActionStatus statusFor(DocumentType type) =>
      documentUploadStatus[type] ?? ActionStatus.idle;

  BecomeProfessionalState copyWith({
    ActionStatus? initialDataStatus,
    List<Category>? categories,
    List<City>? cities,
    List<ServiceArea>? serviceAreas,
    ActionStatus? categoryServicesStatus,
    List<CategoryService>? categoryServices,
    ProfessionalApplication? application,
    ActionStatus? step1Status,
    ActionStatus? step2Status,
    ActionStatus? profilePictureUploadStatus,
    Map<DocumentType, ActionStatus>? documentUploadStatus,
    ActionStatus? submitStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BecomeProfessionalState(
      initialDataStatus: initialDataStatus ?? this.initialDataStatus,
      categories: categories ?? this.categories,
      cities: cities ?? this.cities,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      categoryServicesStatus:
          categoryServicesStatus ?? this.categoryServicesStatus,
      categoryServices: categoryServices ?? this.categoryServices,
      application: application ?? this.application,
      step1Status: step1Status ?? this.step1Status,
      step2Status: step2Status ?? this.step2Status,
      profilePictureUploadStatus:
          profilePictureUploadStatus ?? this.profilePictureUploadStatus,
      documentUploadStatus: documentUploadStatus ?? this.documentUploadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        initialDataStatus,
        categories,
        cities,
        serviceAreas,
        categoryServicesStatus,
        categoryServices,
        application,
        step1Status,
        step2Status,
        profilePictureUploadStatus,
        documentUploadStatus,
        submitStatus,
        errorMessage,
      ];
}
