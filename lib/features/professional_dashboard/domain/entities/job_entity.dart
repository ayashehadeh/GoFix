import 'package:equatable/equatable.dart';

enum JobStatus {
  pending,
  scheduled,   // Accepted
  onTheWay,    // OnTheWay
  inProgress,  // InProgress
  completed,
  declined,
}

class JobEntity extends Equatable {
  final String id;
  final String clientName;
  final String serviceType;
  final String location;
  final DateTime scheduledTime;
  final JobStatus status;
  final String? clientImage;

  const JobEntity({
    required this.id,
    required this.clientName,
    required this.serviceType,
    required this.location,
    required this.scheduledTime,
    required this.status,
    this.clientImage,
  });

  @override
  List<Object?> get props => [
        id,
        clientName,
        serviceType,
        location,
        scheduledTime,
        status,
        clientImage,
      ];
}
