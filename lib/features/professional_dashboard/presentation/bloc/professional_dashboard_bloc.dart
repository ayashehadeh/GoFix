import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/dashboard_usecases.dart';
import 'professional_dashboard_event.dart';
import 'professional_dashboard_state.dart';

class ProfessionalDashboardBloc
    extends Bloc<ProfessionalDashboardEvent, ProfessionalDashboardState> {
  final GetDashboardStats getDashboardStats;
  final GetIncomingRequests getIncomingRequests;
  final GetScheduledJobs getScheduledJobs;
  final AcceptJobRequest acceptJobRequest;
  final DeclineJobRequest declineJobRequest;
  final UpdateJobStatus updateJobStatus;

  ProfessionalDashboardBloc({
    required this.getDashboardStats,
    required this.getIncomingRequests,
    required this.getScheduledJobs,
    required this.acceptJobRequest,
    required this.declineJobRequest,
    required this.updateJobStatus,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<AcceptRequest>(_onAcceptRequest);
    on<DeclineRequest>(_onDeclineRequest);
    on<UpdateStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<ProfessionalDashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<ProfessionalDashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(
    Emitter<ProfessionalDashboardState> emit,
  ) async {
    final statsResult = await getDashboardStats();
    final requestsResult = await getIncomingRequests();
    final jobsResult = await getScheduledJobs();

    statsResult.fold(
      (error) => emit(DashboardError(error)),
      (stats) {
        requestsResult.fold(
          (error) => emit(DashboardError(error)),
          (requests) {
            jobsResult.fold(
              (error) => emit(DashboardError(error)),
              (jobs) {
                emit(DashboardLoaded(
                  stats: stats,
                  incomingRequests: requests,
                  scheduledJobs: jobs,
                ));
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<ProfessionalDashboardState> emit,
  ) async {
    emit(RequestActionLoading());

    final result = await acceptJobRequest(event.jobId);

    result.fold(
      (error) => emit(RequestActionError(error)),
      (_) {
        emit(const RequestActionSuccess('Request accepted successfully'));
        add(RefreshDashboard());
      },
    );
  }

  Future<void> _onDeclineRequest(
    DeclineRequest event,
    Emitter<ProfessionalDashboardState> emit,
  ) async {
    emit(RequestActionLoading());

    final result = await declineJobRequest(event.jobId);

    result.fold(
      (error) => emit(RequestActionError(error)),
      (_) {
        emit(const RequestActionSuccess('Request declined'));
        add(RefreshDashboard());
      },
    );
  }

  Future<void> _onUpdateStatus(
    UpdateStatus event,
    Emitter<ProfessionalDashboardState> emit,
  ) async {
    emit(RequestActionLoading());

    final result = await updateJobStatus(event.jobId, event.status);

    result.fold(
      (error) => emit(RequestActionError(error)),
      (_) {
        emit(const RequestActionSuccess('Status updated successfully'));
        add(RefreshDashboard());
      },
    );
  }
}
