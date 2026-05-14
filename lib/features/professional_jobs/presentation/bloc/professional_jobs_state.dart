import 'package:equatable/equatable.dart';
import '../../domain/entities/pro_job.dart';

abstract class ProfessionalJobsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfessionalJobsInitial extends ProfessionalJobsState {}

class ProfessionalJobsLoading extends ProfessionalJobsState {}

class ProfessionalJobsLoaded extends ProfessionalJobsState {
  final List<ProJob> jobs;
  final bool isUpcomingTab;

  ProfessionalJobsLoaded({
    required this.jobs,
    required this.isUpcomingTab,
  });

  List<ProJob> get activeList => jobs;

  @override
  List<Object?> get props => [jobs, isUpcomingTab];
}

class JobStatusUpdateLoading extends ProfessionalJobsState {
  final String jobId;
  JobStatusUpdateLoading(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class JobStatusUpdateSuccess extends ProfessionalJobsState {
  final ProJob updatedJob;
  final bool movedToPast; // true if completed/cancelled

  JobStatusUpdateSuccess({
    required this.updatedJob,
    required this.movedToPast,
  });

  @override
  List<Object?> get props => [updatedJob, movedToPast];
}

class ProfessionalJobsError extends ProfessionalJobsState {
  final String message;
  ProfessionalJobsError(this.message);
  @override
  List<Object?> get props => [message];
}
