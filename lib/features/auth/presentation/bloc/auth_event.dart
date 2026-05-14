import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  LoginSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  RegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props =>
      [firstName, lastName, email, phone, password, confirmPassword];
}

class VerifyEmailSubmitted extends AuthEvent {
  final String token;
  final String code;
  VerifyEmailSubmitted({required this.token, required this.code});
  @override
  List<Object?> get props => [token, code];
}

class ResendCodeRequested extends AuthEvent {
  final String token;
  ResendCodeRequested({required this.token});
  @override
  List<Object?> get props => [token];
}

class ForgotPasswordSubmitted extends AuthEvent {
  final String email;
  ForgotPasswordSubmitted({required this.email});
  @override
  List<Object?> get props => [email];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String newPassword;
  final String confirmPassword;
  ResetPasswordSubmitted({
    required this.newPassword,
    required this.confirmPassword,
  });
  @override
  List<Object?> get props => [newPassword, confirmPassword];
}

class AuthReset extends AuthEvent {}
