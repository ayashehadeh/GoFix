import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/settings/domain/entities/set_password_entity.dart';
import 'package:gp/features/settings/domain/usecases/set_new_password_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class SetPasswordEvent extends Equatable {
  const SetPasswordEvent();
  @override
  List<Object?> get props => [];
}

class VerifyCurrentPasswordEvent extends SetPasswordEvent {
  final String currentPassword;
  const VerifyCurrentPasswordEvent(this.currentPassword);
  @override
  List<Object?> get props => [currentPassword];
}

class SetNewPasswordSubmitEvent extends SetPasswordEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const SetNewPasswordSubmitEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class SetPasswordState extends Equatable {
  const SetPasswordState();
  @override
  List<Object?> get props => [];
}

class SetPasswordInitial extends SetPasswordState {
  const SetPasswordInitial();
}

class SetPasswordLoading extends SetPasswordState {
  const SetPasswordLoading();
}

class VerifyPasswordSuccess extends SetPasswordState {
  const VerifyPasswordSuccess();
}

class SetPasswordSuccess extends SetPasswordState {
  const SetPasswordSuccess();
}

class SetPasswordError extends SetPasswordState {
  final String message;
  const SetPasswordError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class SetPasswordBloc extends Bloc<SetPasswordEvent, SetPasswordState> {
  final VerifyCurrentPasswordUseCase verifyCurrentPassword;
  final SetNewPasswordUseCase setNewPassword;

  SetPasswordBloc({
    required this.verifyCurrentPassword,
    required this.setNewPassword,
  }) : super(const SetPasswordInitial()) {
    on<VerifyCurrentPasswordEvent>(_onVerify);
    on<SetNewPasswordSubmitEvent>(_onSubmit);
  }

  Future<void> _onVerify(
    VerifyCurrentPasswordEvent event,
    Emitter<SetPasswordState> emit,
  ) async {
    emit(const SetPasswordLoading());
    final result = await verifyCurrentPassword(event.currentPassword);
    result.fold(
      (_) => emit(const SetPasswordError('Incorrect current password.')),
      (_) => emit(const VerifyPasswordSuccess()),
    );
  }

  Future<void> _onSubmit(
    SetNewPasswordSubmitEvent event,
    Emitter<SetPasswordState> emit,
  ) async {
    emit(const SetPasswordLoading());

    final entity = SetPasswordEntity(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    final result = await setNewPassword(entity);
    result.fold(
      (failure) => emit(SetPasswordError(failure.message)),
      (_) => emit(const SetPasswordSuccess()),
    );
  }
}
