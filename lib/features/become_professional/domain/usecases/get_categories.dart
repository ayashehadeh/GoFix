import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/become_professional_repository.dart';

class GetCategories {
  final BecomeProfessionalRepository repository;
  const GetCategories(this.repository);

  Future<Either<Failure, List<Category>>> call() => repository.getCategories();
}
