import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/error/app_error_state.dart';
import 'package:gp/features/settings/domain/entities/feedback_entity.dart';
import 'package:gp/features/settings/domain/usecases/account_usecases.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object?> get props => [];
}

class LogoutEvent extends AccountEvent {
  const LogoutEvent();
}

class DeleteAccountEvent extends AccountEvent {
  const DeleteAccountEvent();
}

class SendFeedbackEvent extends AccountEvent {
  final int stars;
  final String message;
  const SendFeedbackEvent({required this.stars, required this.message});
  @override
  List<Object?> get props => [stars, message];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class LogoutSuccess extends AccountState {
  const LogoutSuccess();
}

class DeleteAccountSuccess extends AccountState {
  const DeleteAccountSuccess();
}

class FeedbackSuccess extends AccountState {
  const FeedbackSuccess();
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final LogoutUseCase logout;
  final DeleteAccountUseCase deleteAccount;
  final SendFeedbackUseCase sendFeedback;

  AccountBloc({
    required this.logout,
    required this.deleteAccount,
    required this.sendFeedback,
  }) : super(const AccountInitial()) {
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<SendFeedbackEvent>(_onSendFeedback);
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    final result = await logout();
    result.fold(
      (f) => emit(const AccountError('Failed to log out')),
      (_) => emit(const LogoutSuccess()),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    final result = await deleteAccount();
    result.fold(
      (f) => emit(const AccountError('Failed to delete account')),
      (_) => emit(const DeleteAccountSuccess()),
    );
  }

  Future<void> _onSendFeedback(
    SendFeedbackEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());
    final result = await sendFeedback(
      FeedbackEntity(stars: event.stars, message: event.message),
    );
    result.fold(
      (f) => emit(const AccountError('Failed to send feedback')),
      (_) => emit(const FeedbackSuccess()),
    );
  }
}
