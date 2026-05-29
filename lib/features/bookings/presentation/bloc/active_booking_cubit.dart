import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/get_upcoming_bookings.dart';
import '../../domain/usecases/get_past_bookings.dart';

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
  final GetPastBookings getPastBookings;

  ActiveBookingCubit({
    required this.getUpcomingBookings,
    required this.getPastBookings,
  }) : super(ActiveBookingInitial());

  Future<void> load() async {
    emit(ActiveBookingLoading());

    // Step 1: upcoming bookings — primary source, same as before.
    final upcomingResult = await getUpcomingBookings();

    String? errorMessage;
    final allBookings = <Booking>[];

    upcomingResult.fold(
      (failure) => errorMessage = failure.message,
      (bookings) => allBookings.addAll(bookings),
    );

    // Step 2: only check past if upcoming returned nothing active. This catches
    // completed-but-unpaid bookings that the backend may have moved to past.
    final active = allBookings.where((b) => b.isUpcoming).toList();
    if (active.isEmpty) {
      final pastResult = await getPastBookings();
      pastResult.fold(
        (failure) => null, // past failure is non-fatal
        (bookings) => allBookings.addAll(bookings),
      );
    }

    final finalActive = allBookings.where((b) => b.isUpcoming).toList();

    if (finalActive.isEmpty) {
      if (errorMessage != null && allBookings.isEmpty) {
        emit(ActiveBookingError(errorMessage!));
      } else {
        emit(ActiveBookingEmpty());
      }
      return;
    }

    emit(ActiveBookingLoaded(_pickMostActive(finalActive)));
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
