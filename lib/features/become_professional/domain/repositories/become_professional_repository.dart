import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../entities/category_service.dart';
import '../entities/document_type.dart';
import '../entities/service_area.dart';
import '../entities/service_pricing.dart';

abstract class BecomeProfessionalRepository {
  // ── Lookups ─────────────────────────────────────────────────────────────

  /// GET /api/categories
  Future<Either<Failure, List<Category>>> getCategories();

  /// GET /api/professionals/services?categoryId={id}
  Future<Either<Failure, List<CategoryService>>> getServicesForCategory(
    int categoryId,
  );

  /// GET /api/professionals/service-areas
  /// Returns all areas; the UI filters by selected city.
  Future<Either<Failure, List<ServiceArea>>> getServiceAreas();

  // ── Application flow ────────────────────────────────────────────────────

  /// POST /api/professionals/profile  — Step 1
  /// Creates the draft profile.
  Future<Either<Failure, Unit>> createProfile({
    required int categoryId,
    required int experienceYears,
    required int cityId,
    required int serviceAreaId,
    required String bio,
  });

  /// PUT /api/professionals/profile/services  — Step 2
  Future<Either<Failure, Unit>> setServices(List<ServicePricing> services);

  /// POST /api/auth/profile-picture  — Step 3 (multipart, separate endpoint)
  Future<Either<Failure, Unit>> uploadProfilePicture(String filePath);

  /// POST /api/professionals/profile/documents  — Step 3 (multipart)
  /// Uses documentType: "identity" | "certification" | "good_conduct"
  Future<Either<Failure, Unit>> uploadDocument({
    required String filePath,
    required DocumentType documentType,
  });

  /// POST /api/professionals/profile/submit  — final
  Future<Either<Failure, Unit>> submitApplication();
}
