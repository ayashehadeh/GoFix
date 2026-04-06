import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.professionalId,
    required super.professionalName,
    required super.professionalRole,
    super.professionalImageUrl,
    required super.serviceName,
    required super.servicePrice,
    required super.scheduledDate,
    required super.scheduledTime,
    required super.address,
    required super.description,
    required super.imageUrls,
    required super.status,
    required super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String? ??
          json['professional_id'] as String? ??
          '',
      professionalName: json['professionalName'] as String? ??
          json['professional_name'] as String? ??
          '',
      professionalRole: json['professionalRole'] as String? ??
          json['professional_role'] as String? ??
          '',
      professionalImageUrl: json['professionalImageUrl'] as String? ??
          json['professional_image_url'] as String?,
      serviceName: json['serviceName'] as String? ??
          json['service_name'] as String? ??
          '',
      servicePrice: json['servicePrice'] as String? ??
          json['service_price'] as String? ??
          '',
      scheduledDate: DateTime.parse(
        json['scheduledDate'] as String? ??
            json['scheduled_date'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      scheduledTime: json['scheduledTime'] as String? ??
          json['scheduled_time'] as String? ??
          '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrls: List<String>.from(
        json['imageUrls'] as List? ?? json['image_urls'] as List? ?? [],
      ),
      status: BookingStatus.fromString(
        json['status'] as String? ?? 'pending',
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            json['created_at'] as String? ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'professional_name': professionalName,
        'professional_role': professionalRole,
        'professional_image_url': professionalImageUrl,
        'service_name': serviceName,
        'service_price': servicePrice,
        'scheduled_date': scheduledDate.toIso8601String(),
        'scheduled_time': scheduledTime,
        'address': address,
        'description': description,
        'image_urls': imageUrls,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };
}
