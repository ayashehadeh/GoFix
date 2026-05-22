import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/repositories/professionals_repository.dart';

class GetMyProfile {
  final ProfessionalsRepository repository;
  const GetMyProfile(this.repository);

  Future<Either<Failure, Professional>> call() => repository.getMyProfile();
}
