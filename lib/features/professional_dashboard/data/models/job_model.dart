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
      // Backend sends a UUID — no client name in BookingDto,
      // so we use userId as the identifier until the backend exposes it.
      id: json['id']?.toString() ?? '',
      clientName: json['clientName'] as String? ?? '',
      serviceType: json['serviceName'] as String? ?? '',
      location: json['address'] as String? ?? '',
      // Backend sends scheduledDate (DateTime) + scheduledTime (String e.g. "09:00 AM")
      // We parse scheduledDate for the DateTime, scheduledTime is display-only in the UI
      scheduledTime: DateTime.tryParse(
            json['scheduledDate'] as String? ?? '',
          ) ??
          DateTime.now(),
      status: _parseStatus(json['status']),
      clientImage: json['professionalImageUrl'] as String?,
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
    case 'pending':      return JobStatus.pending;
    case 'accepted':     return JobStatus.scheduled;
    case 'ontheway':     return JobStatus.onTheWay;
    case 'arrived':      return JobStatus.arrived;
    case 'inprogress':   return JobStatus.inProgress;
    case 'completed':    return JobStatus.completed;
    case 'declined':     return JobStatus.declined;
    default:             return JobStatus.pending;
  }
}
}