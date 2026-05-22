import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call({
    required String email,
    required String password,
  }) =>
      repository.login(email: email, password: password);
}

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Either<Failure, AuthUser>> call({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) =>
      repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
      );
}

class ForgotPasswordUseCase {
  final AuthRepository repository;
  const ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email}) =>
      repository.forgotPassword(email: email);
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  const ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) =>
      repository.resetPassword(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
}
