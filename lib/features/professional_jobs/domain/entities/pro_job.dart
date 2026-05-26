import 'package:equatable/equatable.dart';

enum ProJobStatus {
  pending,    // incoming request not yet accepted
  confirmed,  // accepted, scheduled
  onTheWay,   // professional heading to client
  arrived,    // professional at client's location
  inProgress, // job started
  completed,  // job done → moves to past
  cancelled,  // cancelled → moves to past
}

extension ProJobStatusX on ProJobStatus {
  String get label {
    switch (this) {
      case ProJobStatus.pending:    return 'Pending';
      case ProJobStatus.confirmed:  return 'Confirmed';
      case ProJobStatus.onTheWay:   return 'On the Way';
      case ProJobStatus.arrived:    return 'Arrived';
      case ProJobStatus.inProgress: return 'In Progress';
      case ProJobStatus.completed:  return 'Completed';
      case ProJobStatus.cancelled:  return 'Cancelled';
    }
  }

  bool get isActive =>
      this != ProJobStatus.completed && this != ProJobStatus.cancelled;
}

class ProJob extends Equatable {
  final String id;
  final String clientName;
  final String clientImageUrl;
  final String? clientPhone;
  final String serviceType;
  final String location;
  final DateTime scheduledTime;
  final String price;
  final double? agreedAmount;
  final String description;
  final int pictureCount;
  final ProJobStatus status;

  const ProJob({
    required this.id,
    required this.clientName,
    required this.clientImageUrl,
    this.clientPhone,
    required this.serviceType,
    required this.location,
    required this.scheduledTime,
    required this.price,
    this.agreedAmount,
    required this.description,
    required this.pictureCount,
    required this.status,
  });

  String get formattedDate {
    return '${_monthName(scheduledTime.month)} ${scheduledTime.day}, ${scheduledTime.year}';
  }

  String get formattedTime {
    final h = scheduledTime.hour % 12 == 0 ? 12 : scheduledTime.hour % 12;
    final m = scheduledTime.minute.toString().padLeft(2, '0');
    final period = scheduledTime.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  ProJob copyWith({ProJobStatus? status}) {
    return ProJob(
      id: id,
      clientName: clientName,
      clientImageUrl: clientImageUrl,
      clientPhone: clientPhone,
      serviceType: serviceType,
      location: location,
      scheduledTime: scheduledTime,
      price: price,
      agreedAmount: agreedAmount,
      description: description,
      pictureCount: pictureCount,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id, clientName, clientImageUrl, clientPhone, serviceType,
        location, scheduledTime, price, agreedAmount, description,
        pictureCount, status,
      ];
}
