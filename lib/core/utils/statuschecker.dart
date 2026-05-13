import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gp/core/storage/token_storage.dart';

class ProfessionalStatusChecker {
  final Dio _dio;

  ProfessionalStatusChecker(this._dio);

  /// Check if logged-in user is an approved professional
  /// Uses the application status endpoint
  Future<Map<String, dynamic>> checkStatus() async {
    try {
      final token = await TokenStorage.getToken();

      print('🔍 DEBUG: Token exists: ${token != null && token.isNotEmpty}');

      // If no token, user is not logged in
      if (token == null || token.isEmpty) {
        print('❌ DEBUG: No token found');
        return {'isProfessional': false, 'name': null};
      }

      // Get user name from JWT
      final parts = token.split('.');
      String firstName = '';
      String lastName = '';

      if (parts.length == 3) {
        try {
          final payload = parts[1];
          var normalized = base64Url.normalize(payload);
          var decoded = utf8.decode(base64Url.decode(normalized));
          var payloadMap = json.decode(decoded);
          firstName = payloadMap['first_name'] ?? '';
          lastName = payloadMap['last_name'] ?? '';
        } catch (e) {
          print('⚠️ Could not decode JWT: $e');
        }
      }

      // Call backend to check professional application status
      print('📞 DEBUG: Checking professional application status...');

      try {
        final response = await _dio.get(
          '/professional/application-status',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );

        print('📋 DEBUG: Application Status API Response: ${response.data}');

        final data = response.data;

        // Check if status is "approved"
        final status = data['status']?.toString().toLowerCase();
        final isProfessional = status == 'approved';

        print('👤 DEBUG: Application Status: $status');
        print('✅ DEBUG: Is Professional: $isProfessional');

        final name = '$firstName $lastName'.trim();

        return {
          'isProfessional': isProfessional,
          'name': name.isNotEmpty ? name : 'Professional',
        };
      } catch (apiError) {
        print('❌ DEBUG: API call failed: $apiError');

        // If endpoint doesn't exist or user never applied, return false
        if (apiError is DioException && apiError.response?.statusCode == 404) {
          print('ℹ️ User has not applied to be a professional');
          return {'isProfessional': false, 'name': null};
        }

        return {'isProfessional': false, 'name': null};
      }
    } catch (e) {
      print('❌ DEBUG ERROR: $e');
      return {'isProfessional': false, 'name': null};
    }
  }
}
