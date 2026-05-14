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

  Future<void> verifyEmail({
    required String token,
    required String code,
  });

  Future<void> resendVerificationCode({required String token});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  });
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
  Future<void> verifyEmail({
    required String token,
    required String code,
  }) async {
    await dio.post(
      '/auth/verify-email',
      data: {'code': code},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  @override
  Future<void> resendVerificationCode({required String token}) async {
    await dio.post(
      '/auth/send-verification',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
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
    required String newPassword,
    required String confirmPassword,
  }) async {
    await dio.post(
      '/auth/reset-password',
      data: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }
}
