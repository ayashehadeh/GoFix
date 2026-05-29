import '../models/booking_model.dart';
import '../../domain/entities/booking.dart';
import 'bookings_remote_datasource.dart';

class MockBookingsDataSource implements BookingsRemoteDataSource {
  // ─── Shared description used across the booking detail screens ─────────────
  static const String _pipeDesc = 'Pipe under the kitchen sink has been leaking for 2 days. '
      'Water is dripping onto the cabinet floor. Need it fixed as soon as possible.';

  // ─── In-memory mutable lists so cancel / modify / create all work live ─────
  final List<BookingModel> _upcoming = [
    // Card 1 — Upcoming Bookings/a + Upcoming Booking info + Modification 1/2/3 screens
    BookingModel(
      id: 'b1',
      professionalId: 'p1',
      professionalName: 'Ahmad Khalil',
      professionalRole: 'Plumber',
      professionalImageUrl: null,
      serviceName: 'Pipe Installation',
      servicePrice: '30 - 40 JD',
      scheduledDate: DateTime(2025, 2, 5),
      scheduledTime: '3:00 PM',
      address: 'Apartment, AlJubaiha',
      description: _pipeDesc,
      imageUrls: ['img1.jpg'], // renders as "1 picture attached"
      status: BookingStatus.pending,
      createdAt: DateTime(2025, 2, 1),
    ),

    // Card 2 — Upcoming Bookings/a
    BookingModel(
      id: 'b2',
      professionalId: 'p2',
      professionalName: 'Ali Emad',
      professionalRole: 'Electrician',
      professionalImageUrl: null,
      serviceName: 'Wiring Repair',
      servicePrice: '20 JD',
      scheduledDate: DateTime(2025, 2, 2),
      scheduledTime: '10:00 AM',
      address: 'Villa 12, Sweifieh',
      description: 'The living room circuit breaker keeps tripping whenever the AC is turned on.',
      imageUrls: [],
      status: BookingStatus.confirmed,
      createdAt: DateTime(2025, 1, 29),
    ),

    // Card 3 — Upcoming Bookings/a
    BookingModel(
      id: 'b3',
      professionalId: 'p3',
      professionalName: 'Omar Amer',
      professionalRole: 'Carpenter',
      professionalImageUrl: null,
      serviceName: 'Furniture Assembly',
      servicePrice: '50 JD',
      scheduledDate: DateTime(2025, 1, 2),
      scheduledTime: '11:00 AM',
      address: 'Apartment 4B, Khalda',
      description: 'Need help assembling a new wardrobe and a king-size bed frame.',
      imageUrls: [],
      status: BookingStatus.inProgress,
      createdAt: DateTime(2025, 1, 1),
    ),
  ];

  final List<BookingModel> _past = [
    // Card 1 — Past Bookings/a + Past Booking info/a screens
    BookingModel(
      id: 'b4',
      professionalId: 'p1',
      professionalName: 'Ahmad Khalil',
      professionalRole: 'Plumber',
      professionalImageUrl: null,
      serviceName: 'Pipe Installation',
      servicePrice: '30 JD',
      scheduledDate: DateTime(2025, 2, 5),
      scheduledTime: '3:00 PM',
      address: 'Apartment, AlJubaiha',
      description: _pipeDesc,
      imageUrls: ['img1.jpg'], // renders as "1 picture attached"
      status: BookingStatus.completed,
      createdAt: DateTime(2025, 2, 1),
    ),

    // Card 2 — Past Bookings/a
    BookingModel(
      id: 'b5',
      professionalId: 'p2',
      professionalName: 'Ali Emad',
      professionalRole: 'Electrician',
      professionalImageUrl: null,
      serviceName: 'Light Fixture Installation',
      servicePrice: '20 JD',
      scheduledDate: DateTime(2025, 2, 2),
      scheduledTime: '09:00 AM',
      address: 'Villa 12, Sweifieh',
      description: 'Replace all ceiling lights in the hallway with LED fixtures.',
      imageUrls: [],
      status: BookingStatus.cancelled,
      createdAt: DateTime(2025, 1, 28),
    ),

    // Card 3 — Past Bookings/a
    BookingModel(
      id: 'b6',
      professionalId: 'p3',
      professionalName: 'Omar Amer',
      professionalRole: 'Carpenter',
      professionalImageUrl: null,
      serviceName: 'Door Repair',
      servicePrice: '50 JD',
      scheduledDate: DateTime(2025, 1, 2),
      scheduledTime: '02:00 PM',
      address: 'Apartment 4B, Khalda',
      description: "The bedroom door hinge is broken and the door won't close properly.",
      imageUrls: [],
      status: BookingStatus.completed,
      createdAt: DateTime(2024, 12, 28),
    ),
  ];

  // ─── Helper ────────────────────────────────────────────────────────────────

  BookingModel _findById(String id) {
    return [..._upcoming, ..._past].firstWhere(
      (b) => b.id == id,
      orElse: () => throw Exception('Booking $id not found'),
    );
  }

  // ─── API simulation ────────────────────────────────────────────────────────

  @override
  Future<List<BookingModel>> getUpcomingBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_upcoming);
  }

  @override
  Future<List<BookingModel>> getPastBookings() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_past);
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _findById(bookingId);
  }

  @override
  Future<List<String>> getBookedSlotsForProfessional(String professionalId, DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  /// Creates a new booking and prepends it to the upcoming list.
  @override
  Future<BookingModel> createBooking({
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
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newBooking = BookingModel(
      id: 'b_new_${DateTime.now().millisecondsSinceEpoch}',
      professionalId: professionalId,
      professionalName: 'Ahmad Khalil',
      professionalRole: 'Professional Plumber',
      professionalImageUrl: null,
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
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
    _upcoming.insert(0, newBooking);
    return newBooking;
  }

  /// Updates the booking in-place — used by the Modification 1 → 2 → 3 flow.
  /// The updated booking keeps its original id, professional, and status.
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
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _upcoming.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Booking $bookingId not found');

    final existing = _upcoming[index];
    final updated = BookingModel(
      id: existing.id,
      professionalId: existing.professionalId,
      professionalName: existing.professionalName,
      professionalRole: existing.professionalRole,
      professionalImageUrl: existing.professionalImageUrl,
      serviceName: serviceName,
      servicePrice: servicePrice,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      address: address,
      description: description,
      imageUrls: existing.imageUrls,
      status: existing.status,
      createdAt: existing.createdAt,
    );
    _upcoming[index] = updated;
    return updated;
  }

  /// Removes from upcoming and moves to past list with status = cancelled.
  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _upcoming.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;

    final existing = _upcoming[index];
    _upcoming.removeAt(index);
    _past.insert(
      0,
      BookingModel(
        id: existing.id,
        professionalId: existing.professionalId,
        professionalName: existing.professionalName,
        professionalRole: existing.professionalRole,
        professionalImageUrl: existing.professionalImageUrl,
        serviceName: existing.serviceName,
        servicePrice: existing.servicePrice,
        scheduledDate: existing.scheduledDate,
        scheduledTime: existing.scheduledTime,
        address: existing.address,
        description: existing.description,
        imageUrls: existing.imageUrls,
        status: BookingStatus.cancelled,
        createdAt: existing.createdAt,
      ),
    );
  }

  /// No-op — simulates a successful report submission.
  @override
  Future<void> confirmPayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> submitPaymentAmount(String bookingId, double amount) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> submitReport({
    required String bookingId,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
