import 'package:dio/dio.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUserModel> login({
    required String email,
    required String password,
  });

  Future<AuthUserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> sendVerificationEmail();

  Future<void> verifyEmail({required String code});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  const AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthUserModel.fromLoginResponse(response.data);
  }

  @override
  Future<AuthUserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': 'customer',
      },
    );
    return AuthUserModel.fromLoginResponse(response.data);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await dio.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  @override
  Future<void> sendVerificationEmail() async {
    await dio.post('/auth/send-verification-email');
  }

  @override
  Future<void> verifyEmail({required String code}) async {
    await dio.post('/auth/verify-email', data: {'code': code});
  }
}
