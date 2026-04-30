import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetChats {
  final ChatRepository repository;
  GetChats(this.repository);
  Future<Either<Failure, List<ChatPreviewEntity>>> call() =>
      repository.getChats();
}

class GetMessages {
  final ChatRepository repository;
  GetMessages(this.repository);
  Future<Either<Failure, List<ChatMessageEntity>>> call(String chatId) =>
      repository.getMessages(chatId);
}

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);
  Future<Either<Failure, ChatMessageEntity>> call({
    required String chatId,
    required String text,
    String type = 'text',
    String? attachmentPath,
  }) =>
      repository.sendMessage(
        chatId: chatId,
        text: text,
        type: type,
        attachmentPath: attachmentPath,
      );
}

class DeleteChat {
  final ChatRepository repository;
  DeleteChat(this.repository);
  Future<Either<Failure, void>> call(String chatId) =>
      repository.deleteChat(chatId);
}

class GetOrCreateChat {
  final ChatRepository repository;
  GetOrCreateChat(this.repository);
  Future<Either<Failure, ChatPreviewEntity>> call({
    required String professionalId,
    required String professionalName,
  }) =>
      repository.getOrCreateChat(
        professionalId: professionalId,
        professionalName: professionalName,
      );
}
