import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_service.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/professional_application.dart';
import '../../domain/entities/service_area.dart';

/// Per-action status flag for transient operations (network calls).
enum ActionStatus { idle, loading, success, failure }

/// Single state object covers all 4 screens. Each long-running action has
/// its own status field so the UI can react granularly without juggling
/// multiple state classes.
class BecomeProfessionalState extends Equatable {
  // ── Lookups ─────────────────────────────────────────────────────────────
  final ActionStatus initialDataStatus;
  final List<Category> categories;
  final List<ServiceArea> serviceAreas; // all areas; UI filters by cityId
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

  /// Last error message — surfaced via SnackBar by the UI listener.
  final String? errorMessage;

  const BecomeProfessionalState({
    this.initialDataStatus = ActionStatus.idle,
    this.categories = const [],
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

  /// Unique cities derived from the service areas list. Groups by cityId
  /// and attempts to use cityName from service areas. Falls back to
  /// cityId-based mapping if city names aren't in the API response.
  List<({int id, String name})> get derivedCities {
    final seen = <int>{};
    final result = <({int id, String name})>[];
    for (final area in serviceAreas) {
      if (area.cityId == 0) continue;
      if (seen.add(area.cityId)) {
        // Use cityName from API if available, otherwise map from cityId
        final name = area.cityName ?? _mapCityIdToName(area.cityId);
        result.add((id: area.cityId, name: name));
      }
    }
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  /// Maps cityId to city name. This is used as a fallback when the API
  /// doesn't return city names. Update this mapping based on your backend data.
  String _mapCityIdToName(int cityId) {
    const cityMap = {
      1: 'Amman',
      2: 'Irbid',
      3: 'Zarqa',
      4: 'Aqaba',
    };
    return cityMap[cityId] ?? 'City $cityId';
  }

  ActionStatus statusFor(DocumentType type) =>
      documentUploadStatus[type] ?? ActionStatus.idle;

  BecomeProfessionalState copyWith({
    ActionStatus? initialDataStatus,
    List<Category>? categories,
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
      serviceAreas: serviceAreas ?? this.serviceAreas,
      categoryServicesStatus:
          categoryServicesStatus ?? this.categoryServicesStatus,
      categoryServices: categoryServices ?? this.categoryServices,
      application: application ?? this.application,
      step1Status: step1Status ?? this.step1Status,
      step2Status: step2Status ?? this.step2Status,
      profilePictureUploadStatus:
          profilePictureUploadStatus ?? this.profilePictureUploadStatus,
      documentUploadStatus:
          documentUploadStatus ?? this.documentUploadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        initialDataStatus,
        categories,
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
  /// Maps cityId to city name. This is used as a fallback when the API
  /// doesn't return city names. Update this mapping based on your backend data.
  String _mapCityIdToName(int cityId) {
    const cityMap = {
      1: 'Abu Dhabi',
      2: 'Dubai',
      3: 'Sharjah',
      4: 'Ajman',
      5: 'Ras Al Khaimah',
      6: 'Fujairah',
      7: 'Umm Al Quwain',
    };
    return cityMap[cityId] ?? 'City $cityId';
  }
