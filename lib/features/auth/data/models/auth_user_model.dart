import 'package:gp/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.role,
    required super.token,
  });

  /// Parses the full login/register API response:
  /// { "data": { "token": "...", "user": { "id", "firstName", ... } } }
  factory AuthUserModel.fromLoginResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;

    return AuthUserModel(
      id: user['id'] as String,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String? ?? '',
      email: user['email'] as String? ?? '',
      phone: user['phone'] as String? ?? '',
      role: user['role'] as String? ?? 'customer',
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'role': role,
      };
}
