import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';
//the bloc deals with the usecase.
class GetCategoriesUseCase {

  final HomeRepository repository;
  const GetCategoriesUseCase(this.repository);

  //make the class callable.
  Future<Either<Failure, List<CategoryEntity>>> call() {
    //add business logic.
    return repository.getCategories();
  }
}
