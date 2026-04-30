import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../repositories/reviews_repository.dart';

class DeleteReview {
  final ReviewsRepository repository;

  const DeleteReview(this.repository);

  Future<Either<Failure, void>> call(String reviewId) {
    return repository.deleteReview(reviewId);
  }
}
