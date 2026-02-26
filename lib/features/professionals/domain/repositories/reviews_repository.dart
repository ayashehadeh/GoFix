import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewsRepository {
  
  Future<Either<Failure, List<Review>>> getReviewsByProfessional(
    String professionalId,
  );

  Future<Either<Failure, Review>> addReview({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  });

  Future<Either<Failure, Review>> editReview({
    required String reviewId,
    required double rating,
    required String comment,
  });

  Future<Either<Failure, void>> deleteReview(String reviewId);
}
