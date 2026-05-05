import 'package:equatable/equatable.dart';

abstract class ApplicationStatusEvent extends Equatable {
  const ApplicationStatusEvent();
  @override
  List<Object?> get props => [];
}

class LoadApplicationStatus extends ApplicationStatusEvent {
  const LoadApplicationStatus();
}

class RefreshApplicationStatus extends ApplicationStatusEvent {
  const RefreshApplicationStatus();
}
