import 'package:gp/features/booking/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.workerName,
    required super.workerRole,
    required super.serviceType,
    required super.scheduledDate,
    required super.address,
    required super.price,
    super.notes,
    required super.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      workerName: json['workerName'] as String,
      workerRole: json['workerRole'] as String,
      serviceType: json['serviceType'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      address: json['address'] as String,
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerName': workerName,
        'workerRole': workerRole,
        'serviceType': serviceType,
        'scheduledDate': scheduledDate.toIso8601String(),
        'address': address,
        'price': price,
        'notes': notes,
        'status': status,
      };
}
