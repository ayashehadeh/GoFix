import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  });

  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, void>> sendVerificationEmail();

  Future<Either<Failure, void>> verifyEmail({required String code});
}
