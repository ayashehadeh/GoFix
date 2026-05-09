import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.requestsCount,
    required super.scheduledCount,
    required super.completedCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      requestsCount: json['requestsCount'] ?? json['requests_count'] ?? 0,
      scheduledCount: json['scheduledCount'] ?? json['scheduled_count'] ?? 0,
      completedCount: json['completedCount'] ?? json['completed_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requests_count': requestsCount,
      'scheduled_count': scheduledCount,
      'completed_count': completedCount,
    };
  }
}
