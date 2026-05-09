import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.clientName,
    required super.serviceType,
    required super.location,
    required super.scheduledTime,
    required super.status,
    super.clientImage,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? json['client_name'] ?? '',
      serviceType: json['serviceType'] ?? json['service_type'] ?? '',
      location: json['location'] ?? '',
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : (json['scheduled_time'] != null
              ? DateTime.parse(json['scheduled_time'])
              : DateTime.now()),
      status: _parseStatus(json['status']),
      clientImage: json['clientImage'] ?? json['client_image'],
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
    };
  }

  static JobStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return JobStatus.pending;
      case 'scheduled':
        return JobStatus.scheduled;
      case 'completed':
        return JobStatus.completed;
      case 'declined':
        return JobStatus.declined;
      default:
        return JobStatus.pending;
    }
  }
}
