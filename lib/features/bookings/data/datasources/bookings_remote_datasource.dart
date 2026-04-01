import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../../domain/entities/booking.dart';

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
  Future<void> submitReport({
    required String bookingId,
    required String description,
  });
}

class BookingsRemoteDataSourceImpl implements BookingsRemoteDataSource {
  final Dio dio;

  const BookingsRemoteDataSourceImpl({required this.dio});

  // ── Mock Data ────────────────────────────────────────────────────────────

  static final List<BookingModel> _mockUpcoming = [
    BookingModel(
      id: 'bk-001',
      professionalId: 'pro-001',
      professionalName: 'Ahmed Al-Rashid',
      professionalRole: 'Electrician',
      professionalImageUrl: null,
      serviceName: 'Electrical Wiring Inspection',
      servicePrice: '\$85',
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      scheduledTime: '10:00 AM',
      address: '14 King Faisal St, Amman',
      description: 'Full home wiring inspection and safety check.',
      imageUrls: [],
      status: BookingStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BookingModel(
      id: 'bk-002',
      professionalId: 'pro-002',
      professionalName: 'Sara Mahmoud',
      professionalRole: 'Plumber',
      professionalImageUrl: null,
      serviceName: 'Pipe Leak Repair',
      servicePrice: '\$60',
      scheduledDate: DateTime.now().add(const Duration(days: 5)),
      scheduledTime: '02:00 PM',
      address: '7 Rainbow St, Jabal Amman',
      description: 'Fix leaking pipe under the kitchen sink.',
      imageUrls: [],
      status: BookingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    BookingModel(
      id: 'bk-003',
      professionalId: 'pro-003',
      professionalName: 'Khalid Nasser',
      professionalRole: 'Painter',
      professionalImageUrl: null,
      serviceName: 'Interior Painting',
      servicePrice: '\$200',
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      scheduledTime: '09:00 AM',
      address: '22 Zahran St, Amman',
      description: 'Paint living room and two bedrooms.',
      imageUrls: [],
      status: BookingStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final List<BookingModel> _mockPast = [
    BookingModel(
      id: 'bk-004',
      professionalId: 'pro-004',
      professionalName: 'Lina Hassan',
      professionalRole: 'Cleaner',
      professionalImageUrl: null,
      serviceName: 'Deep Home Cleaning',
      servicePrice: '\$75',
      scheduledDate: DateTime.now().subtract(const Duration(days: 10)),
      scheduledTime: '11:00 AM',
      address: '5 University St, Irbid',
      description: 'Full apartment deep cleaning service.',
      imageUrls: [],
      status: BookingStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    BookingModel(
      id: 'bk-005',
      professionalId: 'pro-005',
      professionalName: 'Omar Zayed',
      professionalRole: 'Handyman',
      professionalImageUrl: null,
      serviceName: 'Furniture Assembly',
      servicePrice: '\$45',
      scheduledDate: DateTime.now().subtract(const Duration(days: 20)),
      scheduledTime: '03:00 PM',
      address: '9 Mecca St, Amman',
      description: 'Assemble bedroom wardrobe and desk.',
      imageUrls: [],
      status: BookingStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
    BookingModel(
      id: 'bk-006',
      professionalId: 'pro-006',
      professionalName: 'Nour Khalil',
      professionalRole: 'AC Technician',
      professionalImageUrl: null,
      serviceName: 'AC Maintenance',
      servicePrice: '\$55',
      scheduledDate: DateTime.now().subtract(const Duration(days: 30)),
      scheduledTime: '01:00 PM',
      address: '3 Gardens St, Amman',
      description: 'Annual AC cleaning and gas refill.',
      imageUrls: [],
      status: BookingStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 32)),
    ),
  ];

  // ── Methods ──────────────────────────────────────────────────────────────

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    // TODO: Replace with real API call when backend is ready:
    // final response = await dio.get('/bookings', queryParameters: {'filter': 'upcoming'});
    // final data = response.data['data'] as List;
    // return data.map((e) => BookingModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockUpcoming;
  }

  @override
  Future<List<BookingModel>> getPastBookings() async {
    // TODO: Replace with real API call when backend is ready:
    // final response = await dio.get('/bookings', queryParameters: {'filter': 'past'});
    // final data = response.data['data'] as List;
    // return data.map((e) => BookingModel.fromJson(e)).toList();

    await Future.delayed(const Duration(milliseconds: 600));
    return _mockPast;
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    // TODO: Replace with real API call when backend is ready:
    // final response = await dio.get('/bookings/$bookingId');
    // return BookingModel.fromJson(response.data['data']);

    await Future.delayed(const Duration(milliseconds: 400));
    return [
      ..._mockUpcoming,
      ..._mockPast,
    ].firstWhere((b) => b.id == bookingId, orElse: () => _mockUpcoming.first);
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
    // TODO: Replace with real API call when backend is ready:
    // final response = await dio.post('/bookings', data: { ... });
    // return BookingModel.fromJson(response.data['data']);

    await Future.delayed(const Duration(milliseconds: 800));
    return BookingModel(
      id: 'bk-new-${DateTime.now().millisecondsSinceEpoch}',
      professionalId: professionalId,
      professionalName: 'New Professional',
      professionalRole: 'Service Provider',
      professionalImageUrl: null,
      serviceName: serviceName,
      servicePrice: servicePrice,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      address: address,
      description: description,
      imageUrls: imageUrls,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> submitReport({
    required String bookingId,
    required String description,
  }) async {
    // TODO: Replace with real API call when backend is ready:
    // await dio.post('/bookings/$bookingId/report', data: {'description': description});

    await Future.delayed(const Duration(milliseconds: 500));
    // Mock success — does nothing for now
  }
}


/*import 'package:dio/dio.dart';
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
*/