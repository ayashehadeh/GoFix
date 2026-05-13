import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource dataSource;
  ChatRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<ChatPreviewEntity>>> getChats() async {
    try {
      final result = await dataSource.getChats();
      return Right(result);
    } catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(
      String chatId) async {
    try {
      final result = await dataSource.getMessages(chatId);
      return Right(result);
    } catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String chatId,
    required String text,
    String type = 'text',
    String? attachmentPath,
  }) async {
    try {
      final result =
          await dataSource.sendMessage(chatId, text, type, attachmentPath);
      return Right(result);
    } catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat(String chatId) async {
    try {
      await dataSource.deleteChat(chatId);
      return const Right(null);
    } catch (e) {
      return Left(_mapFailure(e));
    }
  }

  @override
  Future<Either<Failure, ChatPreviewEntity>> getOrCreateChat({
    required String professionalId,
    required String professionalName,
  }) async {
    try {
      final result = await dataSource.getOrCreateChat(
        professionalId,
        professionalName,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapFailure(e));
    }
  }

  Failure _mapFailure(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final message = data is Map<String, dynamic> ? data['message'] : null;
      if (message is String && message.trim().isNotEmpty) {
        return ServerFailure(message);
      }

      if (error.response?.statusCode != null) {
        return const ServerFailure(
            'Unable to open chat. Please try again later.');
      }
    }

    return ServerFailure(error.toString());
  }
}
