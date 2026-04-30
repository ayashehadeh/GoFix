import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatPreviewEntity>>> getChats();
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(String chatId);
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String chatId,
    required String text,
    String type = 'text',
    String? attachmentPath,
  });
  Future<Either<Failure, void>> deleteChat(String chatId);
  Future<Either<Failure, ChatPreviewEntity>> getOrCreateChat({
    required String professionalId,
    required String professionalName,
  });
}
