import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/review.dart';
import '../../repositories/reviews_repository.dart';

class EditReview {
  final ReviewsRepository repository;

  const EditReview(this.repository);

  Future<Either<Failure, Review>> call({
    required String reviewId,
    required double rating,
    required String comment,
  }) {
    return repository.editReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
    );
  }
}
