import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/usecases/get_availability.dart';
import '../../domain/usecases/save_availability.dart';
import 'availability_event.dart';
import 'availability_state.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetAvailability getAvailability;
  final SaveAvailability saveAvailability;

  AvailabilityBloc({
    required this.getAvailability,
    required this.saveAvailability,
  }) : super(AvailabilityInitial()) {
    on<LoadAvailability>(_onLoadAvailability);
    on<SaveAvailabilityEvent>(_onSaveAvailability);
    on<UpdateAvailabilityToggle>(_onUpdateToggle);
    on<UpdateWorkingDay>(_onUpdateWorkingDay);
    on<UpdateWorkingHours>(_onUpdateWorkingHours);
  }

  Future<void> _onLoadAvailability(
    LoadAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoading());

    final result = await getAvailability(NoParams());

    result.fold(
      (failure) =>
          emit(const AvailabilityError(message: 'Failed to load availability')),
      (availability) {
        // Convert workingDays list to Map
        final selectedDays = {
          'Sun': false,
          'Mon': false,
          'Tue': false,
          'Wed': false,
          'Thu': false,
          'Fri': false,
          'Sat': false,
        };

        for (var day in availability.workingDays) {
          if (selectedDays.containsKey(day)) {
            selectedDays[day] = true;
          }
        }

        emit(AvailabilityLoaded(
          isAvailable: availability.isAvailable,
          selectedDays: selectedDays,
          fromHour: availability.fromHour,
          fromMinute: availability.fromMinute,
          toHour: availability.toHour,
          toMinute: availability.toMinute,
        ));
      },
    );
  }

  Future<void> _onSaveAvailability(
    SaveAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilitySaving());

    final result = await saveAvailability(
      SaveAvailabilityParams(availability: event.availability),
    );

    result.fold(
      (failure) =>
          emit(const AvailabilityError(message: 'Failed to save availability')),
      (_) => emit(AvailabilitySaved()),
    );
  }

  void _onUpdateToggle(
    UpdateAvailabilityToggle event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      emit(currentState.copyWith(isAvailable: event.isAvailable));
    }
  }

  void _onUpdateWorkingDay(
    UpdateWorkingDay event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      final updatedDays = Map<String, bool>.from(currentState.selectedDays);
      updatedDays[event.day] = event.isSelected;
      emit(currentState.copyWith(selectedDays: updatedDays));
    }
  }

  void _onUpdateWorkingHours(
    UpdateWorkingHours event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      emit(currentState.copyWith(
        fromHour: event.fromHour,
        fromMinute: event.fromMinute,
        toHour: event.toHour,
        toMinute: event.toMinute,
      ));
    }
  }
}
