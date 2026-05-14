import 'package:equatable/equatable.dart';

class SetPasswordEntity extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const SetPasswordEntity({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}
