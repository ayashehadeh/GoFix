import 'package:equatable/equatable.dart';

class ChatPreviewEntity extends Equatable {
  final String id;
  final String name;
  final String timeAgo;
  final String? imageUrl;

  const ChatPreviewEntity({
    required this.id,
    required this.name,
    required this.timeAgo,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, timeAgo, imageUrl];
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final String type; // 'text' | 'image' | 'file' | 'audio'
  final String? attachmentPath;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.type = 'text',
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [id, text, isMe, time, type, attachmentPath];
}
