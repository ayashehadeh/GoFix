import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  // TODO: inject remote datasource when .NET backend is ready

  @override
  Future<Either<Failure, BookingEntity>> createBooking(
      BookingEntity booking) async {
    // TODO: call remote datasource
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    // TODO: call remote datasource
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> cancelBooking(int id) async {
    // TODO: call remote datasource
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingStatus(int id) async {
    // TODO: call remote datasource
    throw UnimplementedError();
  }
}
