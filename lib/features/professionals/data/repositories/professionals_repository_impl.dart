import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/professionals/data/datasources/professionals_remote_datasource.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/review.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/domain/repositories/professionals_repository.dart';
import 'package:gp/features/professionals/domain/repositories/reviews_repository.dart';

class ProfessionalsRepositoryImpl implements ProfessionalsRepository {
  final ProfessionalsRemoteDataSource remoteDataSource;

  const ProfessionalsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Professional>>> getProfessionalsByCategory(
      ServiceCategory category) async {
    try {
      final result = await remoteDataSource.getProfessionalsByCategory(category);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Professional>> getProfessionalById(String id) async {
    try {
      final result = await remoteDataSource.getProfessionalById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> getFavorites() async {
    try {
      final result = await remoteDataSource.getFavorites();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String professionalId) async {
    try {
      await remoteDataSource.toggleFavorite(professionalId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> searchProfessionals(
      String query) async {
    try {
      final result = await remoteDataSource.searchProfessionals(query);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Professional>>> filterProfessionals({
    required ServiceCategory category,
    int? minExperienceYears,
    double? maxDistanceKm,
    double? minRating,
  }) async {
    try {
      final result = await remoteDataSource.filterProfessionals(
        category: category,
        minExperienceYears: minExperienceYears,
        maxDistanceKm: maxDistanceKm,
        minRating: minRating,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return ServerFailure(
      e.response?.data?['message'] as String? ?? 'Something went wrong',
    );
  }
}

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ProfessionalsRemoteDataSource remoteDataSource;

  const ReviewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Review>>> getReviewsByProfessional(
      String professionalId) async {
    try {
      final result =
          await remoteDataSource.getReviewsByProfessional(professionalId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> addReview({
    required String professionalId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      final result = await remoteDataSource.addReview(
        professionalId: professionalId,
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Review>> editReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      final result = await remoteDataSource.editReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return ServerFailure(
      e.response?.data?['message'] as String? ?? 'Something went wrong',
    );
  }
}
