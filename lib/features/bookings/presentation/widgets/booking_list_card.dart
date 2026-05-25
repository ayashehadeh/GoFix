import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/booking.dart';

class BookingListCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingListCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status bar on left edge
            _StatusBar(status: booking.status),

            // Avatar
            Padding(
              padding: const EdgeInsets.all(12),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE0E8F0),
                backgroundImage:
                    booking.professionalImageUrl != null ? NetworkImage(booking.professionalImageUrl!) : null,
                child: booking.professionalImageUrl == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.primaryDark,
                        size: 28,
                      )
                    : null,
              ),
            ),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.professionalName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.professionalRole,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Date + price
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    booking.formattedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.servicePrice,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
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

class _StatusBar extends StatelessWidget {
  final BookingStatus status;

  const _StatusBar({required this.status});

  Color get _color {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF3800D);
      case BookingStatus.confirmed:
      case BookingStatus.accepted:
        return const Color(0xFF1565C0);
      case BookingStatus.onTheWay:
        return const Color(0xFF6A1B9A);
      case BookingStatus.arrived:
        return const Color(0xFF00838F);
      case BookingStatus.inProgress:
        return const Color(0xFF2E7D32);
      case BookingStatus.completed:
        return const Color(0xFF757575);
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(
          status.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
