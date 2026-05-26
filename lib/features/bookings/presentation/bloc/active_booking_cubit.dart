import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/get_upcoming_bookings.dart';

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

  ActiveBookingCubit({required this.getUpcomingBookings})
      : super(ActiveBookingInitial());

  Future<void> load() async {
    emit(ActiveBookingLoading());
    final result = await getUpcomingBookings();
    result.fold(
      (failure) => emit(ActiveBookingError(failure.message)),
      (bookings) {
        if (bookings.isEmpty) {
          emit(ActiveBookingEmpty());
        } else {
          emit(ActiveBookingLoaded(_pickMostActive(bookings)));
        }
      },
    );
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
