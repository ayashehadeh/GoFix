import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../datasources/bookings_remote_datasource.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDataSource remoteDataSource;

  const BookingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Booking>>> getUpcomingBookings() async {
    try {
      final result = await remoteDataSource.getUpcomingBookings();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getPastBookings() async {
    try {
      final result = await remoteDataSource.getPastBookings();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    try {
      final result = await remoteDataSource.getBookingById(bookingId);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> createBooking({
    required String professionalId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
    required List<String> imageUrls,
  }) async {
    try {
      final result = await remoteDataSource.createBooking(
        professionalId: professionalId,
        serviceName: serviceName,
        servicePrice: servicePrice,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        address: address,
        description: description,
        imageUrls: imageUrls,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> modifyBooking({
    required String bookingId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
  }) async {
    try {
      final result = await remoteDataSource.modifyBooking(
        bookingId: bookingId,
        serviceName: serviceName,
        servicePrice: servicePrice,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        address: address,
        description: description,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await remoteDataSource.cancelBooking(bookingId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitReport({
    required String bookingId,
    required String description,
  }) async {
    try {
      await remoteDataSource.submitReport(
        bookingId: bookingId,
        description: description,
      );
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
      return NetworkFailure('Network error');
    }
    return ServerFailure(
      e.response?.data?['message'] as String? ?? 'Something went wrong',
    );
  }
}