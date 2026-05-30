import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pro_job.dart';
import '../../domain/usecases/professional_jobs_usecases.dart';
import 'professional_jobs_event.dart';
import 'professional_jobs_state.dart';

class ProfessionalJobsBloc
    extends Bloc<ProfessionalJobsEvent, ProfessionalJobsState> {
  final GetUpcomingJobs getUpcomingJobs;
  final GetPastJobs getPastJobs;
  final UpdateProJobStatus updateJobStatus;
  final CancelProJob cancelProJob;

  // In-memory cache so status updates reflect immediately
  List<ProJob> _upcomingCache = [];
  List<ProJob> _pastCache = [];

  ProfessionalJobsBloc({
    required this.getUpcomingJobs,
    required this.getPastJobs,
    required this.updateJobStatus,
    required this.cancelProJob,
  }) : super(ProfessionalJobsInitial()) {
    on<LoadUpcomingJobs>(_onLoadUpcoming);
    on<LoadPastJobs>(_onLoadPast);
    on<UpdateProJobStatusEvent>(_onUpdateStatus);
    on<CancelProJobEvent>(_onCancelJob);
  }

  Future<void> _onLoadUpcoming(
    LoadUpcomingJobs event,
    Emitter<ProfessionalJobsState> emit,
  ) async {
    emit(ProfessionalJobsLoading());
    final result = await getUpcomingJobs();
    result.fold(
      (failure) => emit(ProfessionalJobsError(failure.message)),
      (jobs) {
        _upcomingCache = jobs;
        emit(ProfessionalJobsLoaded(jobs: jobs, isUpcomingTab: true));
      },
    );
  }

  Future<void> _onLoadPast(
    LoadPastJobs event,
    Emitter<ProfessionalJobsState> emit,
  ) async {
    emit(ProfessionalJobsLoading());
    final result = await getPastJobs();
    result.fold(
      (failure) => emit(ProfessionalJobsError(failure.message)),
      (jobs) {
        _pastCache = jobs;
        emit(ProfessionalJobsLoaded(jobs: jobs, isUpcomingTab: false));
      },
    );
  }

  Future<void> _onUpdateStatus(
    UpdateProJobStatusEvent event,
    Emitter<ProfessionalJobsState> emit,
  ) async {
    emit(JobStatusUpdateLoading(event.jobId));

    final result = await updateJobStatus(
      jobId: event.jobId,
      newStatus: event.newStatus,
    );

    result.fold(
      (failure) => emit(ProfessionalJobsError(failure.message)),
      (updatedJob) {
        final movedToPast = !event.newStatus.isActive;

        if (movedToPast) {
          _upcomingCache =
              _upcomingCache.where((j) => j.id != event.jobId).toList();
          _pastCache = [updatedJob, ..._pastCache];
        } else {
          _upcomingCache = _upcomingCache
              .map((j) => j.id == event.jobId ? updatedJob : j)
              .toList();
        }

        emit(JobStatusUpdateSuccess(
          updatedJob: updatedJob,
          movedToPast: movedToPast,
        ));
      },
    );
  }

  Future<void> _onCancelJob(
    CancelProJobEvent event,
    Emitter<ProfessionalJobsState> emit,
  ) async {
    emit(JobStatusUpdateLoading(event.jobId));

    final result = await cancelProJob(event.jobId, reason: event.reason);

    result.fold(
      (failure) => emit(ProfessionalJobsError(failure.message)),
      (_) {
        final cancelled = _upcomingCache
            .where((j) => j.id == event.jobId)
            .map((j) => j.copyWith(status: ProJobStatus.cancelled))
            .firstOrNull;

        _upcomingCache =
            _upcomingCache.where((j) => j.id != event.jobId).toList();
        if (cancelled != null) _pastCache = [cancelled, ..._pastCache];

        emit(JobStatusUpdateSuccess(
          updatedJob: cancelled ??
              ProJob(
                id: event.jobId,
                clientName: '',
                clientImageUrl: '',
                serviceType: '',
                location: '',
                scheduledTime: DateTime.now(),
                price: '',
                description: '',
                status: ProJobStatus.cancelled,
              ),
          movedToPast: true,
        ));
      },
    );
  }
}
