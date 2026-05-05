import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_application_status.dart';
import 'application_status_event.dart';
import 'application_status_state.dart';

class ApplicationStatusBloc
    extends Bloc<ApplicationStatusEvent, ApplicationStatusState> {
  final GetApplicationStatus getApplicationStatus;

  ApplicationStatusBloc({required this.getApplicationStatus})
      : super(const ApplicationStatusInitial()) {
    on<LoadApplicationStatus>(_onLoad);
    on<RefreshApplicationStatus>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadApplicationStatus event,
    Emitter<ApplicationStatusState> emit,
  ) async {
    emit(const ApplicationStatusLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    RefreshApplicationStatus event,
    Emitter<ApplicationStatusState> emit,
  ) async {
    // Keep current data visible while refreshing — no loading spinner
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<ApplicationStatusState> emit) async {
    final result = await getApplicationStatus();
    result.fold(
      (failure) => emit(ApplicationStatusError(failure.message)),
      (status) => emit(ApplicationStatusLoaded(status)),
    );
  }
}
