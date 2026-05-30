import 'package:equatable/equatable.dart';
import '../../domain/entities/pro_job.dart';

abstract class ProfessionalJobsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUpcomingJobs extends ProfessionalJobsEvent {}

class LoadPastJobs extends ProfessionalJobsEvent {}

class UpdateProJobStatusEvent extends ProfessionalJobsEvent {
  final String jobId;
  final ProJobStatus newStatus;

  UpdateProJobStatusEvent({required this.jobId, required this.newStatus});

  @override
  List<Object?> get props => [jobId, newStatus];
}

class CancelProJobEvent extends ProfessionalJobsEvent {
  final String jobId;
  final String? reason;

  CancelProJobEvent({required this.jobId, this.reason});

  @override
  List<Object?> get props => [jobId, reason];
}
