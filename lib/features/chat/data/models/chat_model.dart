import '../../domain/entities/chat_entity.dart';

class ChatPreviewModel extends ChatPreviewEntity {
  const ChatPreviewModel({
    required super.id,
    required super.name,
    required super.timeAgo,
    super.imageUrl,
  });

  factory ChatPreviewModel.fromJson(Map<String, dynamic> json) {
    return ChatPreviewModel(
      id: (json['id'] as Object?)?.toString() ?? '',
      name: json['name'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? json['time_ago'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'time_ago': timeAgo,
        'image_url': imageUrl,
      };
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.text,
    required super.isMe,
    required super.time,
    super.type = 'text',
    super.attachmentPath,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] as Object?)?.toString() ?? '',
      text: json['text'] as String? ?? '',
      isMe: json['isMe'] as bool? ?? json['is_me'] as bool? ?? false,
      time: json['time'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      // backend sends attachmentPath / attachmentUrl interchangeably
      attachmentPath: json['attachmentPath'] as String? ??
          json['attachment_path'] as String? ??
          json['attachmentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_me': isMe,
        'time': time,
        'type': type,
        'attachment_path': attachmentPath,
      };
}
