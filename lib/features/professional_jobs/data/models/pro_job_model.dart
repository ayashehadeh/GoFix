import '../../domain/entities/pro_job.dart';

class ProJobModel extends ProJob {
  const ProJobModel({
    required super.id,
    required super.clientName,
    required super.clientImageUrl,
    required super.serviceType,
    required super.location,
    super.latitude,
    super.longitude,
    required super.scheduledTime,
    required super.price,
    required super.description,
    required super.pictureCount,
    required super.status,
  });

  factory ProJobModel.fromJson(Map<String, dynamic> json) {
    return ProJobModel(
      id: json['id'] as String,
      clientName: json['clientName'] ?? json['client_name'] ?? '',
      clientImageUrl: json['clientImageUrl'] ?? json['client_image'] ?? '',
      serviceType: json['serviceType'] ?? json['service_type'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : DateTime.parse(json['scheduled_time'] as String),
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      pictureCount: json['pictureCount'] ?? json['picture_count'] ?? 0,
      status: _parseStatus(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'clientImageUrl': clientImageUrl,
        'serviceType': serviceType,
        'location': location,
        'scheduledTime': scheduledTime.toIso8601String(),
        'price': price,
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
