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

class SetNewPasswordSubmitEvent extends SetPasswordEvent {
  final String newPassword;
  final String confirmPassword;

  const SetNewPasswordSubmitEvent({
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [newPassword, confirmPassword];
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
  final SetNewPasswordUseCase setNewPassword;

  SetPasswordBloc({required this.setNewPassword})
      : super(const SetPasswordInitial()) {
    on<SetNewPasswordSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SetNewPasswordSubmitEvent event,
    Emitter<SetPasswordState> emit,
  ) async {
    emit(const SetPasswordLoading());

    final entity = SetPasswordEntity(
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    final result = await setNewPassword(entity);
    result.fold(
      (failure) => emit(
        const SetPasswordError('Failed to reset password. Please try again.'),
      ),
      (_) => emit(const SetPasswordSuccess()),
    );
  }
}
