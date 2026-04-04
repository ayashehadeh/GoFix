import 'package:equatable/equatable.dart';

class SetPasswordEntity extends Equatable {
  final String newPassword;
  final String confirmPassword;

  const SetPasswordEntity({
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [newPassword, confirmPassword];
}
