import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String token;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, role, token];
}
