import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/core/theme/app_text_styles.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';
import 'package:gp/features/professionals/presentation/widgets/star_rating.dart';

class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ProfessionalCard({
    super.key,
    required this.professional,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name + Stars + Favorite ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    professional.name,
                    style: AppTextStyles.sectionTitle,
                  ),
                ),
                StarRating(rating: professional.rating, size: 16),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Icon(
                    professional.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.primaryOrange,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Experience ───────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: AppColors.primaryOrange, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${professional.experienceYears} ${professional.experienceYears == 1 ? 'year' : 'years'} experience',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            // ── Distance ─────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.bookmark_border,
                    color: AppColors.primaryOrange, size: 16),
                const SizedBox(width: 6),
                Text(
                  professional.distanceKm < 1
                      ? '${(professional.distanceKm * 1000).toInt()} m away'
                      : '${professional.distanceKm.toStringAsFixed(1)} Km away',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
