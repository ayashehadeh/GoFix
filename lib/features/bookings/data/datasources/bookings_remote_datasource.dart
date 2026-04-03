import 'package:dio/dio.dart';
import '../models/booking_model.dart';

abstract class BookingsRemoteDataSource {
  Future<List<BookingModel>> getUpcomingBookings();
  Future<List<BookingModel>> getPastBookings();
  Future<BookingModel> getBookingById(String bookingId);

  Future<BookingModel> createBooking({
    required String professionalId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
    required List<String> imageUrls,
  });

  Future<BookingModel> modifyBooking({
    required String bookingId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
  });

  Future<void> cancelBooking(String bookingId);

  Future<void> submitReport({
    required String bookingId,
    required String description,
  });
}

class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  final Dio dio;

  const BookingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    final response = await dio.get(
      '/bookings',
      queryParameters: {'filter': 'upcoming'},
    );
    final data = response.data['data'] as List;
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  @override
  Future<List<BookingModel>> getPastBookings() async {
    final response = await dio.get(
      '/bookings',
      queryParameters: {'filter': 'past'},
    );
    final data = response.data['data'] as List;
    return data.map((e) => BookingModel.fromJson(e)).toList();
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await dio.get('/bookings/$bookingId');
    return BookingModel.fromJson(response.data['data']);
  }

  @override
  Future<BookingModel> createBooking({
    required String professionalId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
    required List<String> imageUrls,
  }) async {
    final response = await dio.post(
      '/bookings',
      data: {
        'professionalId': professionalId,
        'serviceName': serviceName,
        'servicePrice': servicePrice,
        'scheduledDate': scheduledDate.toIso8601String(),
        'scheduledTime': scheduledTime,
        'address': address,
        'description': description,
        'imageUrls': imageUrls,
      },
    );
    return BookingModel.fromJson(response.data['data']);
  }

  @override
  Future<BookingModel> modifyBooking({
    required String bookingId,
    required String serviceName,
    required String servicePrice,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    required String description,
  }) async {
    final response = await dio.put(
      '/bookings/$bookingId',
      data: {
        'serviceName': serviceName,
        'servicePrice': servicePrice,
        'scheduledDate': scheduledDate.toIso8601String(),
        'scheduledTime': scheduledTime,
        'address': address,
        'description': description,
      },
    );
    return BookingModel.fromJson(response.data['data']);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await dio.patch('/bookings/$bookingId/cancel');
  }

  @override
  Future<void> submitReport({
    required String bookingId,
    required String description,
  }) async {
    await dio.post(
      '/bookings/$bookingId/report',
      data: {'description': description},
    );
  }
}
