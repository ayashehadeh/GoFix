import 'package:gp/features/professionals/domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.professionalId,
    required super.bookingId,
    required super.reviewerId,
    required super.reviewerName,
    super.reviewerImageUrl,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String? ??
          json['professional_id'] as String? ??
          '',
      bookingId: json['bookingId'] as String? ??
          json['booking_id'] as String? ??
          '',
      reviewerId: json['reviewerId'] as String? ??
          json['reviewer_id'] as String? ??
          '',
      reviewerName: json['reviewerName'] as String? ??
          json['reviewer_name'] as String? ??
          '',
      reviewerImageUrl: json['reviewerImageUrl'] as String? ??
          json['reviewer_image_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.parse(
              (json['updatedAt'] ?? json['updated_at']) as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'booking_id': bookingId,
        'reviewer_id': reviewerId,
        'reviewer_name': reviewerName,
        'reviewer_image_url': reviewerImageUrl,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}