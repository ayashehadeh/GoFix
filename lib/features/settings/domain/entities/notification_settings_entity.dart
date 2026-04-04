import 'package:equatable/equatable.dart';

class NotificationSettingsEntity extends Equatable {
  final bool bookingConfirmations;
  final bool modificationsCancellations;
  final bool chatMessages;
  final bool supportComplaints;
  final bool appFeedback;

  const NotificationSettingsEntity({
    required this.bookingConfirmations,
    required this.modificationsCancellations,
    required this.chatMessages,
    required this.supportComplaints,
    required this.appFeedback,
  });

  NotificationSettingsEntity copyWith({
    bool? bookingConfirmations,
    bool? modificationsCancellations,
    bool? chatMessages,
    bool? supportComplaints,
    bool? appFeedback,
  }) {
    return NotificationSettingsEntity(
      bookingConfirmations: bookingConfirmations ?? this.bookingConfirmations,
      modificationsCancellations:
          modificationsCancellations ?? this.modificationsCancellations,
      chatMessages: chatMessages ?? this.chatMessages,
      supportComplaints: supportComplaints ?? this.supportComplaints,
      appFeedback: appFeedback ?? this.appFeedback,
    );
  }

  @override
  List<Object?> get props => [
        bookingConfirmations,
        modificationsCancellations,
        chatMessages,
        supportComplaints,
        appFeedback,
      ];
}
