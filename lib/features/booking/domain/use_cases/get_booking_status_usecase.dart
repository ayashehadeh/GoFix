import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingStatusUseCase {
  final BookingRepository repository;
  GetBookingStatusUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(int id) {
    return repository.getBookingStatus(id);
  }
}
