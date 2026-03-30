import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final int id;
  final String workerName;
  final String workerRole;
  final String serviceType;
  final DateTime scheduledDate;
  final String address;
  final double price;
  final String? notes;
  final String status;

  const BookingEntity({
    required this.id,
    required this.workerName,
    required this.workerRole,
    required this.serviceType,
    required this.scheduledDate,
    required this.address,
    required this.price,
    this.notes,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        workerName,
        workerRole,
        serviceType,
        scheduledDate,
        address,
        price,
        notes,
        status,
      ];
}
