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
  final String? reason;

  const UpdateStatus(this.jobId, this.status, {this.reason});

  @override
  List<Object?> get props => [jobId, status, reason];
}

class SubmitPaymentAmountEvent extends ProfessionalDashboardEvent {
  final String jobId;
  final double amount;

  const SubmitPaymentAmountEvent(this.jobId, this.amount);

  @override
  List<Object?> get props => [jobId, amount];
}
