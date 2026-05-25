import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/bookings_repository.dart';

class SubmitPaymentAmount {
  final BookingsRepository repository;
  const SubmitPaymentAmount(this.repository);

  Future<Either<Failure, void>> call(String bookingId, double amount) =>
      repository.submitPaymentAmount(bookingId, amount);
}
