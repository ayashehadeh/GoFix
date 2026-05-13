import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final int requestsCount;
  final int scheduledCount;
  final int completedCount;

  const DashboardStatsEntity({
    required this.requestsCount,
    required this.scheduledCount,
    required this.completedCount,
  });

  @override
  List<Object?> get props => [requestsCount, scheduledCount, completedCount];
}
