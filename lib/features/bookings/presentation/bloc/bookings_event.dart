import 'package:equatable/equatable.dart';

abstract class BookingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUpcomingBookings extends BookingsEvent {}

class LoadPastBookings extends BookingsEvent {}

class LoadBookingById extends BookingsEvent {
  final String bookingId;
  LoadBookingById(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class SubmitReportEvent extends BookingsEvent {
  final String bookingId;
  final String description;

  SubmitReportEvent({
    required this.bookingId,
    required this.description,
  });

  @override
  List<Object?> get props => [bookingId, description];
}

class CreateBookingEvent extends BookingsEvent {
  final String professionalId;
  final String serviceName;
  final String servicePrice;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String address;
  final String description;
  final List<String> imageUrls;

  CreateBookingEvent({
    required this.professionalId,
    required this.serviceName,
    required this.servicePrice,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.address,
    required this.description,
    required this.imageUrls,
  });

  @override
  List<Object?> get props => [
        professionalId,
        serviceName,
        servicePrice,
        scheduledDate,
        scheduledTime,
        address,
        description,
        imageUrls,
      ];
}

class CancelBookingEvent extends BookingsEvent {
  final String bookingId;
  CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class ConfirmPaymentEvent extends BookingsEvent {
  final String bookingId;
  ConfirmPaymentEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class ModifyBookingEvent extends BookingsEvent {
  final String bookingId;
  final String serviceName;
  final String servicePrice;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String address;
  final String description;

  ModifyBookingEvent({
    required this.bookingId,
    required this.serviceName,
    required this.servicePrice,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.address,
    required this.description,
  });

  @override
  List<Object?> get props => [
        bookingId,
        serviceName,
        servicePrice,
        scheduledDate,
        scheduledTime,
        address,
        description,
      ];
}
