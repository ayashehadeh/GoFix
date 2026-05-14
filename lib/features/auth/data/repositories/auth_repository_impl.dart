import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/core/storage/token_storage.dart';
import 'package:gp/features/auth/domain/entities/auth_user.dart';
import 'package:gp/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
          email: email, password: password);
      await TokenStorage.saveToken(
        token: user.token,
        userId: user.id,
        role: user.role,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Login failed. Check your email and password.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final user = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
      );
      await TokenStorage.saveToken(
        token: user.token,
        userId: user.id,
        role: user.role,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Registration failed. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail({
    required String token,
    required String code,
  }) async {
    try {
      await remoteDataSource.verifyEmail(token: token, code: code);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Verification failed. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationCode({
    required String token,
  }) async {
    try {
      await remoteDataSource.resendVerificationCode(token: token);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to resend code. Please try again.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to send reset instructions.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to reset password.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── Helper ──────────────────────────────────────────────────────────────────

  ServerFailure _dioFailure(DioException e, String fallback) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const ServerFailure('No internet connection');
    }
    final msg = e.response?.data?['message'] as String?;
    return ServerFailure(msg ?? fallback);
  }
}
