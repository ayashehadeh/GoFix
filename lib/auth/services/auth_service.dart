import 'package:dio/dio.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.7:5109/api/auth';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String role = 'customer',
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
      });
      return response.data;
   } on DioException catch (e) {
  print('DIO ERROR: ${e.type}');
  print('DIO RESPONSE: ${e.response?.data}');
  print('DIO STATUS: ${e.response?.statusCode}');
  String message = 'Registration failed. Please try again.';
  if (e.response?.data != null) {
    message = e.response?.data['message'] ?? message;
  }
  throw Exception(message);
}
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      String message = 'Login failed. Check your email and password.';
      if (e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      throw Exception(message);
    }
  }

  Future<void> verifyEmail({
    required String token,
    required String code,
  }) async {
    try {
      await _dio.post(
        '/verify-email',
        data: {'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      String message = 'Verification failed. Please try again.';
      if (e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      throw Exception(message);
    }
  }

  Future<void> resendVerificationCode({required String token}) async {
    try {
      await _dio.post(
        '/send-verification',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      String message = 'Failed to resend code. Please try again.';
      if (e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      throw Exception(message);
    }
  }
}