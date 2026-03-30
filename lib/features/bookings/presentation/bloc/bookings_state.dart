import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

abstract class BookingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

// Shown on the My Bookings list page
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

// Shown on the Booking Info / detail page
class BookingDetailLoaded extends BookingsState {
  final Booking booking;
  BookingDetailLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

// Shown while submitting report / creating booking
class BookingActionLoading extends BookingsState {}

class BookingActionSuccess extends BookingsState {
  final String message;
  BookingActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingsError extends BookingsState {
  final String message;
  BookingsError(this.message);

  @override
  List<Object?> get props => [message];
}
