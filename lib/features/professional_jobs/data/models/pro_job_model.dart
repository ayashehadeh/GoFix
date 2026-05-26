import '../../domain/entities/pro_job.dart';

class ProJobModel extends ProJob {
  const ProJobModel({
    required super.id,
    required super.clientName,
    required super.clientImageUrl,
    super.clientPhone,
    required super.serviceType,
    required super.location,
    required super.scheduledTime,
    required super.price,
    super.agreedAmount,
    required super.description,
    required super.pictureCount,
    required super.status,
  });

  factory ProJobModel.fromJson(Map<String, dynamic> json) {
    return ProJobModel(
      id: json['id'] as String,
      clientName: json['clientName'] ?? json['client_name'] ?? '',
      clientImageUrl: json['clientImageUrl'] ?? json['client_image'] ?? '',
      clientPhone: json['clientPhone'] as String?,
      serviceType: json['serviceType'] ?? json['service_type'] ?? '',
      location: json['location'] ?? '',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : DateTime.parse(json['scheduled_time'] as String),
      price: json['price'] ?? '',
      agreedAmount: (json['agreedAmount'] as num?)?.toDouble(),
      description: json['description'] ?? '',
      pictureCount: json['pictureCount'] ?? json['picture_count'] ?? 0,
      status: _parseStatus(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'clientImageUrl': clientImageUrl,
        if (clientPhone != null) 'clientPhone': clientPhone,
        'serviceType': serviceType,
        'location': location,
        'scheduledTime': scheduledTime.toIso8601String(),
        'price': price,
        if (agreedAmount != null) 'agreedAmount': agreedAmount,
        'description': description,
        'pictureCount': pictureCount,
        'status': status.name,
      };

  static ProJobStatus _parseStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'ontheway':
      case 'on_the_way':   return ProJobStatus.onTheWay;
      case 'arrived':      return ProJobStatus.arrived;
      case 'inprogress':
      case 'in_progress':  return ProJobStatus.inProgress;
      case 'completed':    return ProJobStatus.completed;
      case 'cancelled':    return ProJobStatus.cancelled;
      case 'confirmed':    return ProJobStatus.confirmed;
      default:             return ProJobStatus.pending;
    }
  }
}
