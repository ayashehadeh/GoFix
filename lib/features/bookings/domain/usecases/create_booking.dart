import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../repositories/bookings_repository.dart';

class CreateBooking {
  final BookingsRepository repository;
  const CreateBooking(this.repository);

  Future<Either<Failure, Booking>> call({
    required String professionalId,
    required String serviceName,
    String? serviceNameAr,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    double? latitude,
    double? longitude,
    required String description,
    required List<String> imageUrls,
  }) =>
      repository.createBooking(
        professionalId: professionalId,
        serviceName: serviceName,
        serviceNameAr: serviceNameAr,
        servicePrice: servicePrice,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        imageUrls: imageUrls,
      );
}
