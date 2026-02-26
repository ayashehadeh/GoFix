import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String professionalId;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.professionalId,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isEdited => updatedAt != null;

  /// e.g. "2 mins ago", "1 day ago", "5 days ago"
  String get timeAgo {
    final now = DateTime.now();
    final date = updatedAt ?? createdAt;
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return '1 day ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} week ago';
    } else {
      return '${(diff.inDays / 30).floor()} month ago';
    }
  }

  Review copyWith({
    double? rating,
    String? comment,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id,
      professionalId: professionalId,
      bookingId: bookingId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerImageUrl: reviewerImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        professionalId,
        bookingId,
        reviewerId,
        reviewerName,
        reviewerImageUrl,
        rating,
        comment,
        createdAt,
        updatedAt,
      ];
}
