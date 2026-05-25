import 'package:equatable/equatable.dart';

enum JobStatus {
  pending,
  scheduled,
  onTheWay,
  arrived,
  inProgress,
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
  final String? description;
  final List<String> imageUrls;

  const JobEntity({
    required this.id,
    required this.clientName,
    required this.serviceType,
    required this.location,
    required this.scheduledTime,
    required this.status,
    this.clientImage,
    this.description,
    this.imageUrls = const [],
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
        description,
        imageUrls,
      ];
}
