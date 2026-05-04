import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/become_professional_repository.dart';

class UploadProfilePicture {
  final BecomeProfessionalRepository repository;
  const UploadProfilePicture(this.repository);

  Future<Either<Failure, Unit>> call(String filePath) =>
      repository.uploadProfilePicture(filePath);
}
