import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.professionalId,
    required super.professionalName,
    required super.professionalRole,
    super.professionalImageUrl,
    super.clientName,
    required super.serviceName,
    super.serviceNameAr,
    required super.servicePrice,
    required super.scheduledDate,
    required super.scheduledTime,
    required super.address,
    required super.description,
    required super.imageUrls,
    required super.status,
    super.paymentConfirmed,
    super.professionalConfirmedPayment,
    super.agreedAmount,
    super.paymentAgreedAt,
    required super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['id'] as Object).toString(),
      professionalId: (json['professionalId'] as Object).toString(),
      professionalName: json['professionalName'] as String? ?? '',
      professionalRole: json['professionalRole'] as String? ?? '',
      professionalImageUrl: json['professionalImageUrl'] as String?,
      clientName: json['clientName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      serviceNameAr: json['serviceNameAr'] as String? ?? json['service_name_ar'] as String?,
      servicePrice: json['servicePrice'] as String? ?? '',
      scheduledDate: DateTime.parse(
        json['scheduledDate'] as String? ?? DateTime.now().toIso8601String(),
      ),
      scheduledTime: json['scheduledTime'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      status: BookingStatus.fromString(json['status'] as String? ?? 'pending'),
      paymentConfirmed: json['paymentConfirmed'] as bool? ?? false,
      professionalConfirmedPayment: json['professionalConfirmedPayment'] as bool? ?? false,
      agreedAmount: (json['agreedAmount'] as num?)?.toDouble(),
      paymentAgreedAt: json['paymentAgreedAt'] != null ? DateTime.tryParse(json['paymentAgreedAt'] as String) : null,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'professional_name': professionalName,
        'professional_role': professionalRole,
        'professional_image_url': professionalImageUrl,
        'client_name': clientName,
        'service_name': serviceName,
        'service_price': servicePrice,
        'scheduled_date': scheduledDate.toIso8601String(),
        'scheduled_time': scheduledTime,
        'address': address,
        'description': description,
        'image_urls': imageUrls,
        'status': status.name,
        'payment_confirmed': paymentConfirmed,
        'professional_confirmed_payment': professionalConfirmedPayment,
        'agreed_amount': agreedAmount,
        'payment_agreed_at': paymentAgreedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
