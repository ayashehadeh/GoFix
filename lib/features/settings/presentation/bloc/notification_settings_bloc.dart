import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/error/app_error_state.dart';
import 'package:gp/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:gp/features/settings/domain/usecases/get_notification_settings_usecase.dart';
import 'package:gp/features/settings/domain/usecases/update_notification_settings_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class NotificationSettingsEvent extends Equatable {
  const NotificationSettingsEvent();
  @override
  List<Object?> get props => [];
}

class GetNotificationSettingsEvent extends NotificationSettingsEvent {
  const GetNotificationSettingsEvent();
}

class UpdateNotificationSettingsEvent extends NotificationSettingsEvent {
  final NotificationSettingsEntity settings;
  const UpdateNotificationSettingsEvent(this.settings);
  @override
  List<Object?> get props => [settings];
}

class ToggleNotificationEvent extends NotificationSettingsEvent {
  final String key;
  final bool value;
  const ToggleNotificationEvent({required this.key, required this.value});
  @override
  List<Object?> get props => [key, value];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();
  @override
  List<Object?> get props => [];
}

class NotificationSettingsInitial extends NotificationSettingsState {
  const NotificationSettingsInitial();
}

class NotificationSettingsLoading extends NotificationSettingsState {
  const NotificationSettingsLoading();
}

class NotificationSettingsLoaded extends NotificationSettingsState {
  final NotificationSettingsEntity settings;
  const NotificationSettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsUpdating extends NotificationSettingsState {
  final NotificationSettingsEntity settings;
  const NotificationSettingsUpdating(this.settings);
  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsUpdateSuccess extends NotificationSettingsState {
  final NotificationSettingsEntity settings;
  const NotificationSettingsUpdateSuccess(this.settings);
  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsError extends NotificationSettingsState with AppErrorState {
  final String message;
  const NotificationSettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class NotificationSettingsBloc
    extends Bloc<NotificationSettingsEvent, NotificationSettingsState> {
  final GetNotificationSettingsUseCase getNotificationSettings;
  final UpdateNotificationSettingsUseCase updateNotificationSettings;

  NotificationSettingsBloc({
    required this.getNotificationSettings,
    required this.updateNotificationSettings,
  }) : super(const NotificationSettingsInitial()) {
    on<GetNotificationSettingsEvent>(_onGet);
    on<UpdateNotificationSettingsEvent>(_onUpdate);
    on<ToggleNotificationEvent>(_onToggle);
  }

  Future<void> _onGet(
    GetNotificationSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(const NotificationSettingsLoading());
    final result = await getNotificationSettings();
    result.fold(
      (failure) =>
          emit(const NotificationSettingsError('Failed to load settings')),
      (settings) => emit(NotificationSettingsLoaded(settings)),
    );
  }

  Future<void> _onUpdate(
    UpdateNotificationSettingsEvent event,
    Emitter<NotificationSettingsState> emit,
  ) async {
    emit(NotificationSettingsUpdating(event.settings));
    final result = await updateNotificationSettings(event.settings);
    result.fold(
      (failure) =>
          emit(const NotificationSettingsError('Failed to update settings')),
      (_) => emit(NotificationSettingsUpdateSuccess(event.settings)),
    );
  }

  void _onToggle(
    ToggleNotificationEvent event,
    Emitter<NotificationSettingsState> emit,
  ) {
    final current = state;
    NotificationSettingsEntity? currentSettings;

    if (current is NotificationSettingsLoaded) {
      currentSettings = current.settings;
    } else if (current is NotificationSettingsUpdateSuccess) {
      currentSettings = current.settings;
    }

    if (currentSettings == null) return;

    final updated = _applyToggle(currentSettings, event.key, event.value);
    emit(NotificationSettingsLoaded(updated));
    add(UpdateNotificationSettingsEvent(updated));
  }

  NotificationSettingsEntity _applyToggle(
    NotificationSettingsEntity settings,
    String key,
    bool value,
  ) {
    switch (key) {
      case 'bookingConfirmations':
        return settings.copyWith(bookingConfirmations: value);
      case 'modificationsCancellations':
        return settings.copyWith(modificationsCancellations: value);
      case 'chatMessages':
        return settings.copyWith(chatMessages: value);
      case 'supportComplaints':
        return settings.copyWith(supportComplaints: value);
      case 'appFeedback':
        return settings.copyWith(appFeedback: value);
      default:
        return settings;
    }
  }
}
