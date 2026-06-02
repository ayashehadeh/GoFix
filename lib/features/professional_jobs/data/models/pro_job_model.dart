// lib/features/professional_jobs/data/models/pro_job_model.dart

import '../../domain/entities/pro_job.dart';

class ProJobModel extends ProJob {
  const ProJobModel({
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
    super.imageUrls, // ← was: required super.pictureCount
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: _parseScheduledDateTime(
        json['scheduledDate'] as String? ?? json['scheduled_date'] as String?,
        json['scheduledTime'] as String? ?? json['scheduled_time'] as String?,
      ),
      price: json['price'] ?? '',
      agreedAmount: (json['agreedAmount'] as num?)?.toDouble(),
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      status: _parseStatus(json['status'] as String?),
    );
  }

  static DateTime _parseScheduledDateTime(String? dateStr, String? timeStr) {
    // If timeStr is a full ISO timestamp, use it directly.
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
        'imageUrls': imageUrls, // ← was: 'pictureCount': pictureCount
        'status': status.name,
      };

  static ProJobStatus _parseStatus(String? s) {
    switch (s?.toLowerCase()) {
      case 'ontheway':
      case 'on_the_way':
        return ProJobStatus.onTheWay;
      case 'arrived':
        return ProJobStatus.arrived;
      case 'inprogress':
      case 'in_progress':
        return ProJobStatus.inProgress;
      case 'completed':
        return ProJobStatus.completed;
      case 'cancelled':
        return ProJobStatus.cancelled;
      case 'confirmed':
        return ProJobStatus.confirmed;
      default:
        return ProJobStatus.pending;
    }
  }
}
