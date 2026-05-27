import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';

class JobModel extends ProJob {
  const JobModel({
    required super.id,
    required super.clientName,
    required super.clientImageUrl,
    super.clientPhone,
    required super.serviceType,
    required super.location,
    super.latitude,
    super.longitude,
    required super.scheduledTime,
    required super.price,
    super.agreedAmount,
    required super.description,
    super.imageUrls,
    required super.status,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientImageUrl: json['professionalImageUrl'] as String? ?? '',
      clientPhone: json['clientPhone'] as String?,
      serviceType: json['serviceType'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: DateTime.tryParse(
            json['scheduledTime'] as String? ?? '',
          ) ??
          DateTime.now(),
      price: json['price']?.toString() ?? '',
      agreedAmount: (json['agreedAmount'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'serviceType': serviceType,
      'location': location,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status.name,
      'clientImageUrl': clientImageUrl,
      'description': description,
      'imageUrls': imageUrls,
    };
  }

  static ProJobStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ProJobStatus.pending;
      case 'accepted':
        return ProJobStatus.confirmed;
      case 'ontheway':
        return ProJobStatus.onTheWay;
      case 'arrived':
        return ProJobStatus.arrived;
      case 'inprogress':
        return ProJobStatus.inProgress;
      case 'completed':
        return ProJobStatus.completed;
      case 'declined':
      case 'cancelled':
        return ProJobStatus.cancelled;
      default:
        return ProJobStatus.pending;
    }
  }
}
