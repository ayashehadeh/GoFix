import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/get_upcoming_bookings.dart';
import '../../domain/usecases/get_booking_by_id.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class ActiveBookingState {}

class ActiveBookingInitial extends ActiveBookingState {}

class ActiveBookingLoading extends ActiveBookingState {}

class ActiveBookingLoaded extends ActiveBookingState {
  final Booking booking;
  ActiveBookingLoaded(this.booking);
}

class ActiveBookingEmpty extends ActiveBookingState {}

class ActiveBookingError extends ActiveBookingState {
  final String message;
  ActiveBookingError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ActiveBookingCubit extends Cubit<ActiveBookingState> {
  final GetUpcomingBookings getUpcomingBookings;
  final GetBookingById getBookingById;

  static const _lastBookingIdKey = 'active_booking_last_id';

  ActiveBookingCubit({
    required this.getUpcomingBookings,
    required this.getBookingById,
  }) : super(ActiveBookingInitial());

  Future<void> load() async {
    emit(ActiveBookingLoading());
    final result = await getUpcomingBookings();
    await result.fold(
      (failure) async => emit(ActiveBookingError(failure.message)),
      (bookings) async {
        // Guard: exclude anything the backend may have returned that is
        // already fully done (completed + payment confirmed).
        final active = bookings.where((b) => b.isUpcoming).toList();
        if (active.isNotEmpty) {
          final booking = _pickMostActive(active);
          await _saveLastBookingId(booking.id);
          emit(ActiveBookingLoaded(booking));
        } else {
          // The backend's /bookings/upcoming endpoint stops returning a
          // booking once the professional marks it as completed, even though
          // the customer hasn't confirmed payment yet. Fall back to a direct
          // lookup of the last known active booking.
          await _tryFallbackFromLastBooking();
        }
      },
    );
  }

  Future<void> _tryFallbackFromLastBooking() async {
    final lastId = await _loadLastBookingId();
    if (lastId == null) {
      emit(ActiveBookingEmpty());
      return;
    }
    final result = await getBookingById(lastId);
    result.fold(
      (_) => emit(ActiveBookingEmpty()),
      (booking) {
        if (booking.isUpcoming) {
          emit(ActiveBookingLoaded(booking));
        } else {
          // Booking is fully done — stop persisting its ID.
          _clearLastBookingId();
          emit(ActiveBookingEmpty());
        }
      },
    );
  }

  Future<void> _saveLastBookingId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBookingIdKey, id);
  }

  Future<String?> _loadLastBookingId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBookingIdKey);
  }

  Future<void> _clearLastBookingId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastBookingIdKey);
  }

  // Picks the booking in the most urgent active state.
  Booking _pickMostActive(List<Booking> bookings) {
    const priority = [
      BookingStatus.inProgress,
      BookingStatus.arrived,
      BookingStatus.onTheWay,
      BookingStatus.accepted,
      BookingStatus.confirmed,
      BookingStatus.pending,
      BookingStatus.completed,
    ];
    for (final status in priority) {
      final matches = bookings.where((b) => b.status == status);
      if (matches.isNotEmpty) return matches.first;
    }
    return bookings.first;
  }
}
