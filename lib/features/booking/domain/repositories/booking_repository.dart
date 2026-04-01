import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking(BookingEntity booking);
  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
  Future<Either<Failure, Unit>> cancelBooking(int id);
  Future<Either<Failure, BookingEntity>> getBookingStatus(int id);
}
