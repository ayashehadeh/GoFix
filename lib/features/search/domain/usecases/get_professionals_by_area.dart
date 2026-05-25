import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import '../repositories/search_repository.dart';

class GetProfessionalsByArea {
  final SearchRepository repository;
  const GetProfessionalsByArea(this.repository);

  Future<Either<Failure, List<Professional>>> call({
    required int areaId,
    ServiceCategory? category,
  }) =>
      repository.getProfessionalsByArea(
        areaId: areaId,
        category: category,
      );
}
