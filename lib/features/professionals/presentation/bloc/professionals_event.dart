import 'package:equatable/equatable.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';

abstract class ProfessionalsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfessionalsByCategory extends ProfessionalsEvent {
  final ServiceCategory category;
  LoadProfessionalsByCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class LoadProfessionalDetail extends ProfessionalsEvent {
  final String professionalId;
  LoadProfessionalDetail(this.professionalId);
  @override
  List<Object?> get props => [professionalId];
}

class LoadReviews extends ProfessionalsEvent {
  final String professionalId;
  LoadReviews(this.professionalId);
  @override
  List<Object?> get props => [professionalId];
}

class ToggleFavoriteEvent extends ProfessionalsEvent {
  final String professionalId;
  ToggleFavoriteEvent(this.professionalId);
  @override
  List<Object?> get props => [professionalId];
}

class ApplyFilters extends ProfessionalsEvent {
  final ServiceCategory category;
  final int? minExperienceYears;
  final double? maxDistanceKm;
  final double? minRating;

  ApplyFilters({
    required this.category,
    this.minExperienceYears,
    this.maxDistanceKm,
    this.minRating,
  });

  @override
  List<Object?> get props => [category, minExperienceYears, maxDistanceKm, minRating];
}

class AddReviewEvent extends ProfessionalsEvent {
  final String professionalId;
  final String bookingId;
  final double rating;
  final String comment;

  AddReviewEvent({
    required this.professionalId,
    required this.bookingId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [professionalId, bookingId, rating, comment];
}

class EditReviewEvent extends ProfessionalsEvent {
  final String reviewId;
  final double rating;
  final String comment;

  EditReviewEvent({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [reviewId, rating, comment];
}

class DeleteReviewEvent extends ProfessionalsEvent {
  final String reviewId;
  DeleteReviewEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}
