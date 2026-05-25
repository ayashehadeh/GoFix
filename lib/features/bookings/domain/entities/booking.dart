import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  accepted,
  declined,
  onTheWay,
  arrived,
  inProgress,
  completed,
  cancelled;

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'accepted':
        return BookingStatus.accepted;
      case 'declined':
        return BookingStatus.declined;
      case 'ontheway':
        return BookingStatus.onTheWay;
      case 'arrived':
        return BookingStatus.arrived;
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
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
  final bool professionalConfirmedPayment;
  final double? agreedAmount;
  final DateTime? paymentAgreedAt;
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
    this.professionalConfirmedPayment = false,
    this.agreedAmount,
    this.paymentAgreedAt,
    required this.createdAt,
  });

  bool get isUpcoming =>
      status == BookingStatus.pending ||
      status == BookingStatus.confirmed ||
      status == BookingStatus.accepted ||
      status == BookingStatus.onTheWay ||
      status == BookingStatus.arrived ||
      status == BookingStatus.inProgress ||
      (status == BookingStatus.completed && !paymentConfirmed);

  bool get isPast =>
      (status == BookingStatus.completed && paymentConfirmed) ||
      status == BookingStatus.cancelled ||
      status == BookingStatus.declined;

  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
        professionalConfirmedPayment,
        agreedAmount,
        paymentAgreedAt,
        createdAt,
      ];
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.declined:
        return 'Declined';
      case BookingStatus.onTheWay:
        return 'On The Way';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
