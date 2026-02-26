import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/review.dart';
import '../../repositories/reviews_repository.dart';

class GetReviewsByProfessional {
  final ReviewsRepository repository;

  const GetReviewsByProfessional(this.repository);

  Future<Either<Failure, List<Review>>> call(String professionalId) {
    return repository.getReviewsByProfessional(professionalId);
  }
}
