import 'package:equatable/equatable.dart';
import 'package:gp/core/error/app_error_state.dart';
import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

abstract class ProfessionalDashboardState extends Equatable {
  const ProfessionalDashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends ProfessionalDashboardState {}

class DashboardLoading extends ProfessionalDashboardState {}

class DashboardLoaded extends ProfessionalDashboardState {
  final DashboardStatsEntity stats;
  final List<ProJob> incomingRequests;
  final List<ProJob> scheduledJobs;

  const DashboardLoaded({
    required this.stats,
    required this.incomingRequests,
    required this.scheduledJobs,
  });

  @override
  List<Object?> get props => [stats, incomingRequests, scheduledJobs];
}

class DashboardError extends ProfessionalDashboardState with AppErrorState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestActionLoading extends ProfessionalDashboardState {}

class RequestActionSuccess extends ProfessionalDashboardState {
  final String message;

  const RequestActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestActionError extends ProfessionalDashboardState with AppErrorState {
  final String message;

  const RequestActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentAmountSubmitting extends ProfessionalDashboardState {}

class PaymentAmountSubmitted extends ProfessionalDashboardState {}
