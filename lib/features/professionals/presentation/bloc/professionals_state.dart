import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/domain/entities/review.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

abstract class ProfessionalsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfessionalsInitial extends ProfessionalsState {}

class ProfessionalsLoading extends ProfessionalsState {}

class ProfessionalsLoaded extends ProfessionalsState {
  final List<Professional> professionals;
  final ServiceCategory category;

  ProfessionalsLoaded({
    required this.professionals,
    required this.category,
  });

  @override
  List<Object?> get props => [professionals, category];
}

class ProfessionalDetailLoaded extends ProfessionalsState {
  final Professional professional;
  final List<Review> reviews;

  ProfessionalDetailLoaded({
    required this.professional,
    required this.reviews,
  });

  @override
  List<Object?> get props => [professional, reviews];
}

class ReviewsLoading extends ProfessionalsState {
  final Professional professional;
  ReviewsLoading(this.professional);
  @override
  List<Object?> get props => [professional];
}

class ReviewActionSuccess extends ProfessionalsState {
  final Professional professional;
  final List<Review> reviews;
  final String message;

  ReviewActionSuccess({
    required this.professional,
    required this.reviews,
    required this.message,
  });

  @override
  List<Object?> get props => [professional, reviews, message];
}

class ProfessionalsError extends ProfessionalsState {
  final String message;
  ProfessionalsError(this.message);
  @override
  List<Object?> get props => [message];
}
