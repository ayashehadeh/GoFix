import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String phone;
  final String email;
  final String dateOfBirth;
  final String gender;

  const ProfileEntity({
    required this.name,
    required this.phone,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
  });

  ProfileEntity copyWith({
    String? name,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? gender,
  }) {
    return ProfileEntity(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  @override
  List<Object?> get props => [name, phone, email, dateOfBirth, gender];
}
