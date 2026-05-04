import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/professional_application.dart';

abstract class BecomeProfessionalRepository {
  /// Step 1 — create the professional profile (category, bio, experience, city/area)
  Future<Either<Failure, void>> createProfile({
    required int categoryId,
    required String bio,
    required int experienceYears,
  });

  /// Step 1b — set the service area the professional covers
  Future<Either<Failure, void>> setServiceArea(List<int> serviceAreaIds);

  /// Step 2 — set services with pricing
  Future<Either<Failure, void>> setServices(List<ServicePricing> services);

  /// Step 3 — upload profile picture (multipart)
  Future<Either<Failure, void>> uploadProfilePicture(String filePath);

  /// Step 3 — upload a document (identity / certification / good_conduct)
  Future<Either<Failure, void>> uploadDocument({
    required String filePath,
    required String documentType, // "identity" | "certification" | "good_conduct"
  });

  /// Final — submit the application for admin review
  Future<Either<Failure, void>> submitApplication();
}
