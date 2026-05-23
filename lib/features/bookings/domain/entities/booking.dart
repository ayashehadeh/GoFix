import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
      case 'ontheway':
      case 'on_the_way':
      case 'arrived':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
      case 'declined':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class Booking extends Equatable {
  final String id;
  final String professionalId;
  final String professionalName;
  final String professionalRole;
  final String? professionalImageUrl;
  final String clientName;
  final String serviceName;
  final String? serviceNameAr;
  final String servicePrice;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String address;
  final String description;
  final List<String> imageUrls;
  final BookingStatus status;
  final bool paymentConfirmed;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.professionalRole,
    this.professionalImageUrl,
    this.clientName = '',
    required this.serviceName,
    this.serviceNameAr,
    required this.servicePrice,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.address,
    required this.description,
    required this.imageUrls,
    required this.status,
    this.paymentConfirmed = false,
    required this.createdAt,
  });

  bool get isUpcoming =>
      status == BookingStatus.pending ||
      status == BookingStatus.confirmed ||
      status == BookingStatus.inProgress ||
      (status == BookingStatus.completed && !paymentConfirmed);

  bool get isPast =>
      (status == BookingStatus.completed && paymentConfirmed) ||
      status == BookingStatus.cancelled;

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[scheduledDate.month - 1]} ${scheduledDate.day}, ${scheduledDate.year}';
  }

  @override
  List<Object?> get props => [
        id,
        professionalId,
        professionalName,
        professionalRole,
        professionalImageUrl,
        clientName,
        serviceName,
        serviceNameAr,
        servicePrice,
        scheduledDate,
        scheduledTime,
        address,
        description,
        imageUrls,
        status,
        paymentConfirmed,
        createdAt,
      ];
}
