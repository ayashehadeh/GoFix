import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_service.dart';
import '../repositories/become_professional_repository.dart';

class GetServicesForCategory {
  final BecomeProfessionalRepository repository;
  const GetServicesForCategory(this.repository);

  Future<Either<Failure, List<CategoryService>>> call(int categoryId) =>
      repository.getServicesForCategory(categoryId);
}
