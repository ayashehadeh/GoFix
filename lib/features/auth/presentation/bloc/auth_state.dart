import 'package:equatable/equatable.dart';
import 'package:gp/features/auth/domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegistered extends AuthState {
  final AuthUser user;
  AuthRegistered(this.user);
  @override
  List<Object?> get props => [user];
}

/// Login succeeded — navigate to home
class AuthLoggedIn extends AuthState {
  final AuthUser user;
  AuthLoggedIn(this.user);
  @override
  List<Object?> get props => [user];
}

/// Forgot password email sent — navigate to CheckYourMail page
class AuthForgotPasswordSent extends AuthState {}

/// Password reset succeeded — navigate to PasswordChanged page
class AuthPasswordReset extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
