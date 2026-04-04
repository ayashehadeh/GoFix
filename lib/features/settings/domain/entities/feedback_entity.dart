import 'package:equatable/equatable.dart';

class FeedbackEntity extends Equatable {
  final int stars;
  final String message;

  const FeedbackEntity({required this.stars, required this.message});

  @override
  List<Object?> get props => [stars, message];
}
