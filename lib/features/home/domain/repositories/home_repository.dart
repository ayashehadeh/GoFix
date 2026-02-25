import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';

//specify what it can do without being concerned with the how.

abstract class HomeRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
}
