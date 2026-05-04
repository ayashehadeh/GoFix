import 'package:dio/dio.dart';
import 'package:gp/features/professionals/data/models/professional_model.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/search/domain/entities/search_result.dart';
import '../models/area_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<ProfessionalModel>> searchProfessionals(String query);
  Future<List<AreaResultModel>> searchAreas(String query);
  Future<List<ServiceResult>> searchServices(String query);
  Future<List<ProfessionalModel>> getProfessionalsByArea({
    required String areaName,
    ServiceCategory? category,
  });

  // Recent searches (require auth)
  Future<List<RecentSearchModel>> getRecentSearches();
  Future<void> recordSearch(String query);
  Future<void> deleteRecentSearch(String id);
  Future<void> clearRecentSearches();
}

// ─── Model for a single recent search row ────────────────────────────────────

class RecentSearchModel {
  final String id;
  final String query;

  const RecentSearchModel({required this.id, required this.query});

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      id: json['id']?.toString() ?? '',
      query: json['query'] as String? ?? '',
    );
  }
}

// ─── Real implementation ──────────────────────────────────────────────────────

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio dio;

  const SearchRemoteDataSourceImpl({required this.dio});

  // Maps ServiceCategory enum → backend categoryId
  int? _categoryId(ServiceCategory? category) {
    if (category == null) return null;
    switch (category) {
      case ServiceCategory.plumbing:        return 1;
      case ServiceCategory.electricalWork:  return 2;
      case ServiceCategory.acRepair:        return 3;
      case ServiceCategory.carpentry:       return 4;
      case ServiceCategory.painting:        return 5;
      case ServiceCategory.cleaning:        return 6;
      case ServiceCategory.movingServices:  return 7;
      case ServiceCategory.applianceRepair: return 8;
    }
  }

  @override
  Future<List<ProfessionalModel>> searchProfessionals(String query) async {
    // Piggybacks on the unified search — extracts the professionals section
    final results = await _unifiedSearch(query);
    return results.professionals;
  }

  @override
  Future<List<AreaResultModel>> searchAreas(String query) async {
    final results = await _unifiedSearch(query);
    return results.areas;
  }

  @override
  Future<List<ServiceResult>> searchServices(String query) async {
    final results = await _unifiedSearch(query);
    return results.services;
  }

  /// Calls `GET /api/search?q={query}&limit=10` and parses grouped results.
  Future<_UnifiedPayload> _unifiedSearch(String query) async {
    final response = await dio.get(
      '/search',
      queryParameters: {'q': query, 'limit': 10},
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};

    // ── Professionals ──────────────────────────────────────────────────────
    final rawPros = data['professionals'] as List? ?? [];
    final professionals = rawPros
        .map((e) => ProfessionalModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // ── Areas ──────────────────────────────────────────────────────────────
    final rawAreas = data['areas'] as List? ?? [];
    final areas = rawAreas.map((e) {
      final map = e as Map<String, dynamic>;
      return AreaResultModel(
        name: map['name'] as String? ?? '',
        city: map['city'] as String? ?? '',
        proCount: (map['availableProfessionalCount'] as num? ?? 0).toInt(),
      );
    }).toList();

    // ── Services ───────────────────────────────────────────────────────────
    final rawServices = data['services'] as List? ?? [];
    final services = rawServices.map((e) {
      final map = e as Map<String, dynamic>;
      final categoryName = map['category'] as String? ?? '';
      final category = ServiceCategory.values.firstWhere(
        (c) => c.displayName.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => ServiceCategory.plumbing,
      );
      return ServiceResult(
        serviceName: map['name'] as String? ?? '',
        category: category,
        proCount:
            (map['availableProfessionalCount'] as num? ?? 0).toInt(),
      );
    }).toList();

    return _UnifiedPayload(
      professionals: professionals,
      areas: areas,
      services: services,
    );
  }

  @override
  Future<List<ProfessionalModel>> getProfessionalsByArea({
    required String areaName,
    ServiceCategory? category,
  }) async {
    final response = await dio.get(
      '/professionals/by-area',
      queryParameters: {
        'areaName': areaName,
        if (_categoryId(category) != null) 'categoryId': _categoryId(category),
      },
    );
    final data = response.data['data'] as List? ?? [];
    return data
        .map((e) => ProfessionalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Recent searches ───────────────────────────────────────────────────────

  @override
  Future<List<RecentSearchModel>> getRecentSearches() async {
    final response = await dio.get('/search/recent');
    final data = response.data['data'] as List? ?? [];
    return data
        .map((e) => RecentSearchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> recordSearch(String query) async {
    await dio.post('/search/recent', data: {'query': query});
  }

  @override
  Future<void> deleteRecentSearch(String id) async {
    await dio.delete('/search/recent/$id');
  }

  @override
  Future<void> clearRecentSearches() async {
    await dio.delete('/search/recent');
  }
}

// ─── Internal helper ──────────────────────────────────────────────────────────

class _UnifiedPayload {
  final List<ProfessionalModel> professionals;
  final List<AreaResultModel> areas;
  final List<ServiceResult> services;

  const _UnifiedPayload({
    required this.professionals,
    required this.areas,
    required this.services,
  });
}