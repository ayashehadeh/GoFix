import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/auth/domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final RegisterUseCase register;
  final VerifyEmailUseCase verifyEmail;
  final ResendVerificationCodeUseCase resendCode;
  final ForgotPasswordUseCase forgotPassword;
  final ResetPasswordUseCase resetPassword;

  AuthBloc({
    required this.login,
    required this.register,
    required this.verifyEmail,
    required this.resendCode,
    required this.forgotPassword,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<VerifyEmailSubmitted>(_onVerifyEmail);
    on<ResendCodeRequested>(_onResendCode);
    on<ForgotPasswordSubmitted>(_onForgotPassword);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<AuthReset>((_, emit) => emit(AuthInitial()));
  }

  Future<void> _onLogin(
      LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await login(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthLoggedIn(user)),
    );
  }

  Future<void> _onRegister(
      RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await register(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthRegistered(user)),
    );
  }

  Future<void> _onVerifyEmail(
      VerifyEmailSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result =
        await verifyEmail(token: event.token, code: event.code);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthEmailVerified()),
    );
  }

  Future<void> _onResendCode(
      ResendCodeRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resendCode(token: event.token);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthCodeResent()),
    );
  }

  Future<void> _onForgotPassword(
      ForgotPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await forgotPassword(email: event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthForgotPasswordSent()),
    );
  }

  Future<void> _onResetPassword(
      ResetPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resetPassword(
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordReset()),
    );
  }
}
