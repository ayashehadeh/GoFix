import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/bookings_repository.dart';

class SubmitReport {
  final BookingsRepository repository;
  const SubmitReport(this.repository);

  Future<Either<Failure, void>> call({
    required String bookingId,
    required String description,
  }) => repository.submitReport(bookingId: bookingId, description: description);
}
