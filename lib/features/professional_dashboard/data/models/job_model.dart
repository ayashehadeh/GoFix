import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.clientName,
    required super.serviceType,
    required super.location,
    super.latitude,
    super.longitude,
    required super.scheduledTime,
    required super.status,
    super.clientImage,
    super.description,
    super.imageUrls,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id']?.toString() ?? '',
      clientName: json['clientName'] as String? ?? '',
      serviceType: json['serviceName'] as String? ?? '',
      location: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: DateTime.tryParse(
            json['scheduledDate'] as String? ?? '',
          ) ??
          DateTime.now(),
      status: _parseStatus(json['status']),
      clientImage: json['professionalImageUrl'] as String?,
      description: json['description'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'service_type': serviceType,
      'location': location,
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status.name,
      'client_image': clientImage,
      'description': description,
      'image_urls': imageUrls,
    };
  }

  static JobStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return JobStatus.pending;
      case 'accepted':
        return JobStatus.scheduled;
      case 'ontheway':
        return JobStatus.onTheWay;
      case 'arrived':
        return JobStatus.arrived;
      case 'inprogress':
        return JobStatus.inProgress;
      case 'completed':
        return JobStatus.completed;
      case 'declined':
        return JobStatus.declined;
      default:
        return JobStatus.pending;
    }
  }
}
