import 'package:equatable/equatable.dart';
import 'package:gp/core/error/app_error_state.dart';
import '../../domain/entities/booking.dart';

abstract class BookingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsLoaded extends BookingsState {
  final List<Booking> upcomingBookings;
  final List<Booking> pastBookings;
  final bool isUpcomingTab;

  BookingsLoaded({
    required this.upcomingBookings,
    required this.pastBookings,
    required this.isUpcomingTab,
  });

  List<Booking> get activeList =>
      isUpcomingTab ? upcomingBookings : pastBookings;

  BookingsLoaded copyWith({bool? isUpcomingTab}) => BookingsLoaded(
        upcomingBookings: upcomingBookings,
        pastBookings: pastBookings,
        isUpcomingTab: isUpcomingTab ?? this.isUpcomingTab,
      );

  @override
  List<Object?> get props => [upcomingBookings, pastBookings, isUpcomingTab];
}

class BookingDetailLoaded extends BookingsState {
  final Booking booking;
  BookingDetailLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingActionLoading extends BookingsState {}

class BookingActionSuccess extends BookingsState {
  final String message;
  BookingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful cancel — the page pops back to My Bookings.
class BookingCancelledSuccess extends BookingsState {}

/// Emitted after a successful modify — the success page is shown.
class BookingModifiedSuccess extends BookingsState {}

class ConfirmPaymentSuccess extends BookingsState {}

class ConfirmPaymentError extends BookingsState with AppErrorState {
  final String message;
  ConfirmPaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingsError extends BookingsState with AppErrorState {
  final String message;
  BookingsError(this.message);

  @override
  List<Object?> get props => [message];
}
