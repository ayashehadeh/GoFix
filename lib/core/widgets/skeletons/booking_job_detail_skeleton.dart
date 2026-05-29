import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton for booking/job detail screens.
/// Layout: person card → details card → description card → bottom bar.
class BookingJobDetailSkeleton extends StatelessWidget {
  const BookingJobDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Professional / client card
                  _card(
                    child: Row(
                      children: [
                        _circle(56),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _box(w: 140, h: 14),
                              const SizedBox(height: 8),
                              _box(w: 100, h: 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details card (title + 5 rows)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(w: 110, h: 14),
                        const SizedBox(height: 14),
                        ...List.generate(5, (i) => _detailRow(isLast: i == 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description card
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(w: 130, h: 14),
                        const SizedBox(height: 14),
                        _box(w: double.infinity, h: 12),
                        const SizedBox(height: 8),
                        _box(w: double.infinity, h: 12),
                        const SizedBox(height: 8),
                        _box(w: 180, h: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Row(
              children: [
                Expanded(child: _box(w: double.infinity, h: 50, r: 12)),
                const SizedBox(width: 10),
                _box(w: 50, h: 50, r: 12),
                const SizedBox(width: 10),
                _box(w: 50, h: 50, r: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _box(w: 20, h: 20, r: 4),
              const SizedBox(width: 14),
              _box(w: 160, h: 12),
            ],
          ),
        ),
        if (!isLast)
          Container(height: 1, color: Colors.white),
      ],
    );
  }
}

Widget _card({required Widget child}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );

Widget _circle(double size) => Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );

Widget _box({required double w, required double h, double r = 4}) => Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
