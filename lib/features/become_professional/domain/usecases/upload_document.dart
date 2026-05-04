import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_type.dart';
import '../repositories/become_professional_repository.dart';

class UploadDocument {
  final BecomeProfessionalRepository repository;
  const UploadDocument(this.repository);

  Future<Either<Failure, Unit>> call({
    required String filePath,
    required DocumentType documentType,
  }) =>
      repository.uploadDocument(
        filePath: filePath,
        documentType: documentType,
      );
}
