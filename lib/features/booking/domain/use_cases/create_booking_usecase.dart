import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;
  CreateBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(BookingEntity booking) {
    return repository.createBooking(booking);
  }
}
