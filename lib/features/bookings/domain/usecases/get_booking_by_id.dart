import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../repositories/bookings_repository.dart';

class GetBookingById {
  final BookingsRepository repository;
  const GetBookingById(this.repository);

  Future<Either<Failure, Booking>> call(String bookingId) =>
      repository.getBookingById(bookingId);
}
