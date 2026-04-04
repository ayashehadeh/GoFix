import 'package:gp/features/settings/domain/entities/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({required super.stars, required super.message});

  Map<String, dynamic> toJson() => {
        'stars': stars,
        'message': message,
      };

  factory FeedbackModel.fromEntity(FeedbackEntity entity) => FeedbackModel(
        stars: entity.stars,
        message: entity.message,
      );
}
