import 'package:equatable/equatable.dart';
import '../../domain/entities/application_status_entity.dart';

abstract class ApplicationStatusState extends Equatable {
  const ApplicationStatusState();
  @override
  List<Object?> get props => [];
}

class ApplicationStatusInitial extends ApplicationStatusState {
  const ApplicationStatusInitial();
}

class ApplicationStatusLoading extends ApplicationStatusState {
  const ApplicationStatusLoading();
}

class ApplicationStatusLoaded extends ApplicationStatusState {
  final ApplicationStatusEntity status;
  const ApplicationStatusLoaded(this.status);
  @override
  List<Object?> get props => [status];
}

class ApplicationStatusError extends ApplicationStatusState {
  final String message;
  const ApplicationStatusError(this.message);
  @override
  List<Object?> get props => [message];
}
