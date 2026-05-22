import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/bookings_repository.dart';

class ConfirmPayment {
  final BookingsRepository repository;
  const ConfirmPayment(this.repository);

  Future<Either<Failure, void>> call(String bookingId) =>
      repository.confirmPayment(bookingId);
}
