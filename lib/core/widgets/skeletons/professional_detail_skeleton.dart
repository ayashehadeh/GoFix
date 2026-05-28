import 'package:flutter/material.dart';
import 'package:gp/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton for the ProfessionalDetailPage.
class ProfessionalDetailSkeleton extends StatelessWidget {
  const ProfessionalDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Dark header ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 28,
            left: 20,
            right: 20,
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.35),
            child: Column(
              children: [
                // Back chevron
                Align(
                  alignment: Alignment.centerLeft,
                  child: _sBox(w: 28, h: 28, r: 6),
                ),
                const SizedBox(height: 16),
                // Avatar
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 14),
                // Name + subtitle
                _sBox(w: 150, h: 16),
                const SizedBox(height: 8),
                _sBox(w: 100, h: 12),
              ],
            ),
          ),
        ),

        // ── Tabs row ────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              children: [
                _sBox(w: 70, h: 36, r: 20),
                const SizedBox(width: 10),
                _sBox(w: 68, h: 36, r: 20),
                const SizedBox(width: 10),
                _sBox(w: 62, h: 36, r: 20),
                const SizedBox(width: 10),
                _sBox(w: 90, h: 36, r: 20),
              ],
            ),
          ),
        ),

        // ── Content blocks ───────────────────────────────────────────
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _sBox(w: double.infinity, h: 100, r: 14),
                  const SizedBox(height: 14),
                  _sBox(w: double.infinity, h: 80, r: 14),
                  const SizedBox(height: 14),
                  _sBox(w: double.infinity, h: 100, r: 14),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom bar ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(child: _sBox(w: double.infinity, h: 50, r: 14)),
                const SizedBox(width: 10),
                _sBox(w: 50, h: 50, r: 14),
                const SizedBox(width: 10),
                _sBox(w: 50, h: 50, r: 14),
              ],
            ),
          ),
        ),
      ],
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
