import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingsRepository {
  Future<Either<Failure, List<Booking>>> getUpcomingBookings();
  Future<Either<Failure, List<Booking>>> getPastBookings();
  Future<Either<Failure, Booking>> getBookingById(String bookingId);

  Future<Either<Failure, Booking>> createBooking({
    required String professionalId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
    required List<String> imageUrls,
  });

  Future<Either<Failure, Booking>> modifyBooking({
    required String bookingId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
  });

  Future<Either<Failure, void>> cancelBooking(String bookingId);

  Future<Either<Failure, void>> submitReport({
    required String bookingId,
    required String description,
  });
}
