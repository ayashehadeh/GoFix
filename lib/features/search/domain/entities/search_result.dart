import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

// ─── Area result ──────────────────────────────────────────────────────────────

class AreaResult extends Equatable {
  final int id;
  final String name;
  final String city;
  final int proCount;

  const AreaResult({
    required this.id,
    required this.name,
    required this.city,
    required this.proCount,
  });

  @override
  List<Object?> get props => [id, name, city, proCount];
}

// ─── Service result ───────────────────────────────────────────────────────────
// Represents a named service (e.g. "Pipe Installation") that matched the query.
// Tapping it navigates to the category professionals page for that service's category.

class ServiceResult extends Equatable {
  final int serviceId;
  final String serviceName;
  final ServiceCategory category;
  final int proCount;

  const ServiceResult({
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.proCount,
  });

  @override
  List<Object?> get props => [serviceId, serviceName, category, proCount];
}

// ─── Unified search result ────────────────────────────────────────────────────

class SearchResults extends Equatable {
  final List<Professional> professionals; // matched by name
  final List<AreaResult> areas;           // matched by area name
  final List<ServiceResult> services;     // matched by service name

  final String query;

  const SearchResults({
    required this.professionals,
    required this.areas,
    required this.services,
    required this.query,
  });

  bool get isEmpty =>
      professionals.isEmpty && areas.isEmpty && services.isEmpty;

  @override
  List<Object?> get props => [professionals, areas, services, query];
}

// ─── Area professionals result ────────────────────────────────────────────────

class AreaProfessionalsResult extends Equatable {
  final AreaResult area;
  final List<Professional> professionals;
  final ServiceCategory? activeCategory;

  const AreaProfessionalsResult({
    required this.area,
    required this.professionals,
    this.activeCategory,
  });

  @override
  List<Object?> get props => [area, professionals, activeCategory];
}
