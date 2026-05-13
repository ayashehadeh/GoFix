import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.requestsCount,
    required super.scheduledCount,
    required super.completedCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      // Backend returns: { "requests": int, "scheduled": int, "completed": int }
      requestsCount: json['requests'] as int? ?? 0,
      scheduledCount: json['scheduled'] as int? ?? 0,
      completedCount: json['completed'] as int? ?? 0,
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