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
      serviceType: json['serviceType'] as String? ?? json['serviceName'] as String? ?? '',
      location: json['location'] as String? ?? json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      scheduledTime: _parseScheduledDateTime(
        json['scheduledDate'] as String?,
        json['scheduledTime'] as String?,
      ),
      price: json['servicePrice']?.toString() ?? json['price']?.toString() ?? '',
      agreedAmount: (json['agreedAmount'] as num?)?.toDouble(),
      description: json['description'] as String? ?? '',
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      status: _parseStatus(json['status']),
    );
  }

  static DateTime _parseScheduledDateTime(String? dateStr, String? timeStr) {
    // If scheduledTime is a full ISO datetime (ProJobDto format), use it directly
    if (timeStr != null) {
      final full = DateTime.tryParse(timeStr);
      if (full != null) return full;
    }
    // Parse the date part from scheduledDate
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    if (date == null) return DateTime.now();
    // Parse time string like "3:00 PM" or "10:00 AM"
    if (timeStr != null && timeStr.isNotEmpty) {
      final ampm = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false).firstMatch(timeStr);
      if (ampm != null) {
        int hour = int.parse(ampm.group(1)!);
        final minute = int.parse(ampm.group(2)!);
        final isPm = ampm.group(3)!.toUpperCase() == 'PM';
        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;
        return DateTime(date.year, date.month, date.day, hour, minute);
      }
      // 24-hour fallback "HH:mm" or "HH:mm:ss"
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) return DateTime(date.year, date.month, date.day, h, m);
      }
    }
    return date;
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
