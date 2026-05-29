import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/bookings_repository.dart';

class CancelBooking {
  final BookingsRepository repository;
  const CancelBooking(this.repository);

  Future<Either<Failure, void>> call(String bookingId, {String? reason}) =>
      repository.cancelBooking(bookingId, reason: reason);
}
