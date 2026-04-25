import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:gp/features/professionals/domain/entities/professional.dart';

class SearchProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const SearchProfessionalCard({
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _Avatar(professional: professional),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              professional.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${professional.category.displayName} · ${professional.experienceYears} years',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF888888)),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onFavoriteTap,
                        child: Icon(
                          professional.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: professional.isFavorite
                              ? AppColors.primaryOrange
                              : const Color(0xFFCCCCCC),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.primaryOrange, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        professional.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${professional.reviewCount})',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF666666)),
                      ),
                      if (professional.serviceAreas.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(color: Color(0xFF666666))),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'In ${professional.serviceAreas.first}',
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF666666)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Price + Book button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        professional.services.isNotEmpty
                            ? professional.services.first.priceDisplay
                            : '—',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar with initials fallback ────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Professional professional;

  const _Avatar({required this.professional});

  Color get _bgColor {
    final colors = [
      const Color(0xFFFFE8DB),
      const Color(0xFFEAF3DE),
      const Color(0xFFEEE8F5),
      const Color(0xFFE6F0FF),
      const Color(0xFFFFECEC),
    ];
    return colors[professional.name.hashCode.abs() % colors.length];
  }

  Color get _textColor {
    final colors = [
      const Color(0xFF993C1D),
      const Color(0xFF3B6D11),
      const Color(0xFF534AB7),
      const Color(0xFF2C5FB0),
      const Color(0xFF993333),
    ];
    return colors[professional.name.hashCode.abs() % colors.length];
  }

  String get _initials {
    final parts = professional.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return professional.name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _bgColor,
      backgroundImage: professional.profileImageUrl != null
          ? NetworkImage(professional.profileImageUrl!)
          : null,
      child: professional.profileImageUrl == null
          ? Text(
              _initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            )
          : null,
    );
  }
}
