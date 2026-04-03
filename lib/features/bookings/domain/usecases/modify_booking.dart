import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../repositories/bookings_repository.dart';

class ModifyBooking {
  final BookingsRepository repository;
  const ModifyBooking(this.repository);

  Future<Either<Failure, Booking>> call({
    required String bookingId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
  }) =>
      repository.modifyBooking(
        bookingId: bookingId,
        serviceName: serviceName,
        servicePrice: servicePrice,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        address: address,
        description: description,
      );
}
