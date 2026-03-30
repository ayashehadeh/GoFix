import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../repositories/bookings_repository.dart';

class GetUpcomingBookings {
  final BookingsRepository repository;
  const GetUpcomingBookings(this.repository);

  Future<Either<Failure, List<Booking>>> call() =>
      repository.getUpcomingBookings();
}
