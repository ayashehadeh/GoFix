import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton for the CategoryProfessionalsPage list body
/// (search bar + filter button + professional card rows).
class CategoryProfessionalsSkeleton extends StatelessWidget {
  const CategoryProfessionalsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search + filter bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Professional card list
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const _ProfCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _ProfCardSkeleton extends StatelessWidget {
  const _ProfCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sBox(w: double.infinity, h: 14),
                  const SizedBox(height: 8),
                  _sBox(w: 140, h: 11),
                  const SizedBox(height: 6),
                  _sBox(w: 100, h: 10),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _sBox(w: 40, h: 22, r: 10),
                const SizedBox(height: 8),
                _sBox(w: 32, h: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sBox({required double w, required double h, double r = 4}) =>
    Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
