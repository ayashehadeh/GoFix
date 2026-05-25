import 'package:equatable/equatable.dart';

abstract class ProfessionalDashboardEvent extends Equatable {
  const ProfessionalDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends ProfessionalDashboardEvent {}

class RefreshDashboard extends ProfessionalDashboardEvent {}

class AcceptRequest extends ProfessionalDashboardEvent {
  final String jobId;

  const AcceptRequest(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class DeclineRequest extends ProfessionalDashboardEvent {
  final String jobId;

  const DeclineRequest(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class UpdateStatus extends ProfessionalDashboardEvent {
  final String jobId;
  final String status;

  const UpdateStatus(this.jobId, this.status);

  @override
  List<Object?> get props => [jobId, status];
}

class SubmitPaymentAmountEvent extends ProfessionalDashboardEvent {
  final String jobId;
  final double amount;

  const SubmitPaymentAmountEvent(this.jobId, this.amount);

  @override
  List<Object?> get props => [jobId, amount];
}
