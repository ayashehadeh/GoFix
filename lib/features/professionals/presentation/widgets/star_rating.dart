import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showNumber;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final filled = index < rating.floor();
          final half = !filled && index < rating;
          return Icon(
            filled
                ? Icons.star
                : half
                    ? Icons.star_half
                    : Icons.star_border,
            color: AppColors.star,
            size: size,
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
