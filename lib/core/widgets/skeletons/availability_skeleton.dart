import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton for the availability form (toggle card + 7 day rows).
/// Each card lives outside the shimmer so it stays white;
/// the placeholder shapes inside are grey against it.
class AvailabilitySkeleton extends StatelessWidget {
  const AvailabilitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Calendar icon placeholder ─────────────────────────────
          Center(
            child: _shimmerCircle(100),
          ),
          const SizedBox(height: 28),

          // ── Availability toggle card ──────────────────────────────
          _ShimmerCard(
            height: 64,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 140, height: 13),
                    const SizedBox(height: 6),
                    _shimmerBox(width: 100, height: 11),
                  ],
                ),
                _shimmerBox(width: 44, height: 26, radius: 13),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── "Working Schedule" heading ────────────────────────────
          _shimmerBox(width: 160, height: 14),
          const SizedBox(height: 8),
          _shimmerBox(width: 220, height: 11),
          const SizedBox(height: 16),

          // ── 7 day rows ────────────────────────────────────────────
          ...List.generate(7, (_) => const _DayRowSkeleton()),
        ],
      ),
    );
  }
}

class _DayRowSkeleton extends StatelessWidget {
  const _DayRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return _ShimmerCard(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Day chip
            _shimmerBox(width: 42, height: 42, radius: 8),
            const SizedBox(width: 14),
            // Day name + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 80, height: 13),
                  const SizedBox(height: 6),
                  _shimmerBox(width: 50, height: 10),
                ],
              ),
            ),
            // Toggle circle
            _shimmerCircle(22),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// White card (outside shimmer) + shimmer wrapping its shapes.
class _ShimmerCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;

  const _ShimmerCard({
    required this.child,
    required this.borderRadius,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

Widget _shimmerBox({required double width, required double height, double radius = 4}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

Widget _shimmerCircle(double size) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
  );
}
