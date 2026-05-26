import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../bookings/domain/entities/booking.dart';

class ActiveBookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const ActiveBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  Color _statusColor(BookingStatus status) {
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
    final statusColor = _statusColor(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status strip
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Avatar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE0E8F0),
                  backgroundImage: booking.professionalImageUrl != null
                      ? NetworkImage(booking.professionalImageUrl!)
                      : null,
                  child: booking.professionalImageUrl == null
                      ? const Icon(Icons.person, color: AppColors.primaryDark, size: 24)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content — expands to fill remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        booking.professionalName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              booking.formattedDate,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              booking.scheduledTime,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Status pill + arrow in one row, centered vertically
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StatusPill(status: booking.status),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final BookingStatus status;

  const _StatusPill({required this.status});

  (Color, Color) get _colors {
    switch (status) {
      case BookingStatus.pending:
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      case BookingStatus.confirmed:
      case BookingStatus.accepted:
        return (const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case BookingStatus.onTheWay:
        return (const Color(0xFFF3E5F5), const Color(0xFF6A1B9A));
      case BookingStatus.arrived:
        return (const Color(0xFFE0F7FA), const Color(0xFF00838F));
      case BookingStatus.inProgress:
        return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case BookingStatus.completed:
        return (const Color(0xFFF5F5F5), const Color(0xFF757575));
      case BookingStatus.cancelled:
      case BookingStatus.declined:
        return (const Color(0xFFFFEBEE), const Color(0xFFC62828));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, text) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
