import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../entities/review.dart';
import '../../repositories/reviews_repository.dart';

class AddReview {
  final ReviewsRepository repository;

  const AddReview(this.repository);

  Future<Either<Failure, Review>> call({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  }) {
    return repository.addReview(
      professionalId: professionalId,
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
  }
}
