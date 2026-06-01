import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/get_upcoming_bookings.dart';
import '../../domain/usecases/get_booking_by_id.dart';
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
  final GetBookingById getBookingById;
  final GetPastBookings getPastBookings;

  Timer? _pollingTimer;
  bool _fetching = false;

  ActiveBookingCubit({
    required this.getUpcomingBookings,
    required this.getBookingById,
    required this.getPastBookings,
  }) : super(ActiveBookingInitial());

  Future<void> load() async {
    if (_fetching) return;
    _fetching = true;

    final previousState = state;
    final isFirstLoad = previousState is ActiveBookingInitial || previousState is ActiveBookingError;
    if (isFirstLoad) emit(ActiveBookingLoading());

    final result = await _fetch();
    _fetching = false;

    if (!isFirstLoad) {
      // Silent refresh: only emit if something actually changed.
      if (_hasChanged(previousState, result)) {
        _emitResult(result);
      }
      return;
    }

    _emitResult(result);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => load());
  }

  Future<_FetchResult> _fetch() async {
    String? errorMessage;
    final allBookings = <Booking>[];

    final upcomingResult = await getUpcomingBookings();
    upcomingResult.fold(
      (failure) => errorMessage = failure.message,
      (bookings) => allBookings.addAll(bookings),
    );

    final active = allBookings.where((b) => b.isUpcoming).toList();
    if (active.isEmpty) {
      final pastResult = await getPastBookings();
      pastResult.fold(
        (failure) => null,
        (bookings) => allBookings.addAll(bookings),
      );
    }

    final finalActive = allBookings.where((b) => b.isUpcoming).toList();
    if (finalActive.isEmpty) {
      return _FetchResult(
        errorMessage: (errorMessage != null && allBookings.isEmpty) ? errorMessage : null,
        isEmpty: true,
      );
    }
    return _FetchResult(booking: _pickMostActive(finalActive));
  }

  bool _hasChanged(ActiveBookingState previous, _FetchResult result) {
    if (previous is ActiveBookingLoaded && result.booking != null) {
      return previous.booking.id != result.booking!.id ||
          previous.booking.status != result.booking!.status;
    }
    if (previous is ActiveBookingEmpty && result.isEmpty && result.errorMessage == null) {
      return false;
    }
    return true;
  }

  void _emitResult(_FetchResult result) {
    if (result.booking != null) {
      emit(ActiveBookingLoaded(result.booking!));
    } else if (result.errorMessage != null) {
      emit(ActiveBookingError(result.errorMessage!));
    } else {
      emit(ActiveBookingEmpty());
    }
  }

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

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}

class _FetchResult {
  final Booking? booking;
  final String? errorMessage;
  final bool isEmpty;

  _FetchResult({this.booking, this.errorMessage, this.isEmpty = false});
}
