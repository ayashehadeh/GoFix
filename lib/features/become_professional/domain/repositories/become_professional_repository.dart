import 'package:dartz/dartz.dart';
import 'package:gp/features/become_professional/domain/entities/city.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../entities/category_service.dart';
import '../entities/document_type.dart';
import '../entities/service_area.dart';
import '../entities/service_pricing.dart';
import '../entities/working_hours_schedule.dart';

abstract class BecomeProfessionalRepository {
  // ── Lookups ─────────────────────────────────────────────────────────────

  /// GET /api/categories
  Future<Either<Failure, List<Category>>> getCategories();

  /// GET /api/professionals/services?categoryId={id}
  Future<Either<Failure, List<CategoryService>>> getServicesForCategory(
    int categoryId,
  );

  /// GET /api/professionals/service-areas
  Future<Either<Failure, List<ServiceArea>>> getServiceAreas();

  /// GET /api/professionals/cities
  Future<Either<Failure, List<City>>> getCities();

  // ── Application flow ────────────────────────────────────────────────────

  /// POST /api/professionals/profile  — Step 1
  /// NOTE: serviceAreaId removed — service areas are set separately in Step 3a.
  Future<Either<Failure, Unit>> createProfile({
    required int categoryId,
    required int experienceYears,
    double? latitude,
    double? longitude,
    required String bio,
  });

  /// PUT /api/professionals/profile/services  — Step 2
  Future<Either<Failure, Unit>> setServices(List<ServicePricing> services);

  /// PUT /api/professionals/profile/service-areas  — Step 3a
  /// Sends the full list of selected service area IDs (supports multiple).
  Future<Either<Failure, Unit>> setServiceAreas(List<int> serviceAreaIds);

  /// PUT /api/professionals/profile/working-hours  — Step 3b
  Future<Either<Failure, Unit>> setWorkingHours(
      List<WorkingHoursSchedule> schedules);

  /// POST /api/professionals/profile/picture  — Step 3 (multipart)
  Future<Either<Failure, Unit>> uploadProfilePicture(String filePath);

  /// POST /api/professionals/profile/documents  — Step 3 (multipart)
  /// Uses documentType: "identity" | "certification" | "good_conduct"
  Future<Either<Failure, Unit>> uploadDocument({
    required String filePath,
    required DocumentType documentType,
    String? name,
    String? issuedBy,
    int? issuedYear,
  });

  /// POST /api/professionals/profile/submit  — final
  Future<Either<Failure, Unit>> submitApplication();
}
