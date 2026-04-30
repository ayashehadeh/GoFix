import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateChat {
  final ChatRepository repository;
  GetOrCreateChat(this.repository);

  Future<Either<Failure, ChatPreviewEntity>> call({
    required String professionalId,
    required String professionalName,
  }) async {
    return await repository.getOrCreateChat(
      professionalId: professionalId,
      professionalName: professionalName,
    );
  }
}
