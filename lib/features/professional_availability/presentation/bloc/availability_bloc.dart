import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professional_availability/domain/usecases/get_availability.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/usecases/save_availability.dart';
import 'availability_event.dart';
import 'availability_state.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetAvailability getAvailability;
  final SaveWorkingHours saveWorkingHours;
  final ToggleAvailability toggleAvailability;

  AvailabilityBloc({
    required this.getAvailability,
    required this.saveWorkingHours,
    required this.toggleAvailability,
  }) : super(AvailabilityInitial()) {
    on<LoadAvailability>(_onLoad);
    on<ToggleAvailabilityEvent>(_onToggleAvailability);
    on<ToggleWorkingDay>(_onToggleWorkingDay);
    on<UpdateDaySchedule>(_onUpdateDaySchedule);
    on<SaveWorkingHoursEvent>(_onSaveWorkingHours);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Builds a full 7-day map from a list of DaySchedule.
  /// Days not in the list get null (= day off).
  Map<String, DaySchedule?> _buildScheduleMap(List<DaySchedule> schedules) {
    final map = <String, DaySchedule?>{
      for (final day in AvailabilityEntity.orderedDays) day: null,
    };
    for (final s in schedules) {
      map[s.day] = s;
    }
    return map;
  }

  /// Default schedule applied when a day is toggled on for the first time.
  DaySchedule _defaultSchedule(String day) => DaySchedule(
        day: day,
        openTime: '08:00',
        closeTime: '17:00',
      );

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoading());

    final result = await getAvailability(NoParams());

    result.fold(
      (failure) => emit(AvailabilityError(message: failure.message)),
      (entity) => emit(AvailabilityLoaded(
        isAvailable: entity.isAvailable,
        schedules: _buildScheduleMap(entity.schedules),
      )),
    );
  }

  Future<void> _onToggleAvailability(
    ToggleAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    if (state is! AvailabilityLoaded) return;
    final current = state as AvailabilityLoaded;

    // Optimistic UI — update toggle immediately, show subtle loading state
    emit(AvailabilityTogglingAvailability(
      isAvailable: event.isAvailable,
      schedules: current.schedules,
    ));

    final result = await toggleAvailability(
      ToggleAvailabilityParams(isAvailable: event.isAvailable),
    );

    result.fold(
      (failure) {
        // Revert on failure
        emit(current);
        emit(AvailabilityError(message: failure.message));
      },
      (_) => emit(AvailabilityLoaded(
        isAvailable: event.isAvailable,
        schedules: current.schedules,
      )),
    );
  }

  void _onToggleWorkingDay(
    ToggleWorkingDay event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is! AvailabilityLoaded) return;
    final current = state as AvailabilityLoaded;

    final updatedSchedules = Map<String, DaySchedule?>.from(current.schedules);

    if (current.isWorkingDay(event.day)) {
      // Day is on → turn it off
      updatedSchedules[event.day] = null;
    } else {
      // Day is off → turn it on with default hours
      updatedSchedules[event.day] = _defaultSchedule(event.day);
    }

    emit(current.copyWith(schedules: updatedSchedules));
  }

  void _onUpdateDaySchedule(
    UpdateDaySchedule event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is! AvailabilityLoaded) return;
    final current = state as AvailabilityLoaded;

    final updatedSchedules = Map<String, DaySchedule?>.from(current.schedules);
    updatedSchedules[event.day] = DaySchedule(
      day: event.day,
      openTime: event.openTime,
      closeTime: event.closeTime,
    );

    emit(current.copyWith(schedules: updatedSchedules));
  }

  Future<void> _onSaveWorkingHours(
    SaveWorkingHoursEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    if (state is! AvailabilityLoaded) return;
    final current = state as AvailabilityLoaded;

    emit(AvailabilitySaving(
      isAvailable: current.isAvailable,
      schedules: current.schedules,
    ));

    final result = await saveWorkingHours(
      SaveWorkingHoursParams(schedules: current.workingSchedules),
    );

    result.fold(
      (failure) {
        emit(current);
        emit(AvailabilityError(message: failure.message));
      },
      (_) => emit(AvailabilitySaved(
        isAvailable: current.isAvailable,
        schedules: current.schedules,
      )),
    );
  }
}