import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';

class JobModel extends ProJob {
  const JobModel({
    required super.id,
    required super.clientName,
    required super.clientImageUrl,
    super.clientPhone,
    required super.serviceType,
    super.serviceTypeAr,
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
      serviceType: json['serviceType'] as String? ?? json['serviceName'] as String? ?? '',
      serviceTypeAr: json['serviceTypeAr'] as String? ?? json['service_type_ar'] as String? ?? json['serviceNameAr'] as String?,
      location: json['location'] as String? ?? json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: _parseScheduledDateTime(
        json['scheduledDate'] as String?,
        json['scheduledTime'] as String?,
      ),
      price: json['price']?.toString() ?? '',
      agreedAmount: (json['agreedAmount'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      status: _parseStatus(json['status']),
    );
  }

  static DateTime _parseScheduledDateTime(String? dateStr, String? timeStr) {
    // Try the time field alone first — backend may send a full ISO timestamp.
    if (timeStr != null && timeStr.isNotEmpty) {
      final full = DateTime.tryParse(timeStr);
      if (full != null) return full;
    }

    // Parse the date part.
    final date = dateStr != null && dateStr.isNotEmpty
        ? DateTime.tryParse(dateStr) ?? DateTime.now()
        : DateTime.now();

    if (timeStr == null || timeStr.isEmpty) return date;

    // Parse a time string like "10:00 AM", "14:30", "09:00:00".
    final upper = timeStr.trim().toUpperCase();
    final isPM = upper.endsWith('PM');
    final isAM = upper.endsWith('AM');
    final clean = upper.replaceAll('AM', '').replaceAll('PM', '').trim();
    final parts = clean.split(':');

    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    if (isPM && hour < 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
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
