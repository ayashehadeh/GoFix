import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/professional_application.dart';
import '../repositories/become_professional_repository.dart';

/// Orchestrates the full multi-step application flow in one shot.
/// The BLoC calls each step individually via the repository;
/// this use case is kept as a convenience wrapper for the final submit.
class SubmitProfessionalApplication {
  final BecomeProfessionalRepository repository;

  const SubmitProfessionalApplication(this.repository);

  Future<Either<Failure, void>> call(ProfessionalApplication application) async {
    // Step 1 — create profile
    final step1 = await repository.createProfile(
      categoryId: application.categoryId,
      bio: application.workDescription,
      experienceYears: int.tryParse(application.experienceLevel) ?? 0,
    );
    if (step1.isLeft()) return step1;

    // Step 1b — set service area
    final step1b = await repository.setServiceArea([application.serviceAreaId]);
    if (step1b.isLeft()) return step1b;

    // Step 2 — set services & pricing
    final step2 = await repository.setServices(application.services);
    if (step2.isLeft()) return step2;

    // Step 3a — upload profile picture
    if (application.profileImagePath != null) {
      final picResult = await repository.uploadProfilePicture(
        application.profileImagePath!,
      );
      if (picResult.isLeft()) return picResult;
    }

    // Step 3b — upload identity document
    if (application.idImagePath != null) {
      final idResult = await repository.uploadDocument(
        filePath: application.idImagePath!,
        documentType: 'identity',
      );
      if (idResult.isLeft()) return idResult;
    }

    // Step 3c — upload certification (optional)
    if (application.certificationImagePath != null) {
      final certResult = await repository.uploadDocument(
        filePath: application.certificationImagePath!,
        documentType: 'certification',
      );
      if (certResult.isLeft()) return certResult;
    }

    // Step 3d — upload good conduct (optional)
    if (application.conductImagePath != null) {
      final conductResult = await repository.uploadDocument(
        filePath: application.conductImagePath!,
        documentType: 'good_conduct',
      );
      if (conductResult.isLeft()) return conductResult;
    }

    // Final — submit for admin review
    return repository.submitApplication();
  }
}
