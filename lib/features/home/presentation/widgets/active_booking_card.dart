import 'package:flutter/material.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
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

  static const _phases = [
    (label: 'On the Way',  subtitle: 'Professional is heading to you'),
    (label: 'Arrived',     subtitle: 'Professional is at your location'),
    (label: 'In Progress', subtitle: 'Work is currently underway'),
    (label: 'Completed',   subtitle: 'Service has been completed'),
  ];

  // 0-3 for tracker phases, -1 for pre-phase statuses
  int get _activePhaseIndex {
    switch (booking.status) {
      case BookingStatus.onTheWay:
        return 0;
      case BookingStatus.arrived:
        return 1;
      case BookingStatus.inProgress:
        return 2;
      case BookingStatus.completed:
        return 3;
      default:
        return -1;
    }
  }

  Color _prePhasePillColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF3800D);
      case BookingStatus.confirmed:
      case BookingStatus.accepted:
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activePhaseIndex;
    final showTracker = activeIndex >= 0;

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
              // Left colour strip — always orange for active bookings
              Container(
                width: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Info row ──────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFE0E8F0),
                            backgroundImage: booking.professionalImageUrl != null
                                ? NetworkImage(booking.professionalImageUrl!)
                                : null,
                            child: booking.professionalImageUrl == null
                                ? const Icon(Icons.person,
                                    color: AppColors.primaryDark, size: 22)
                                : null,
                          ),
                          const SizedBox(width: 10),

                          // Name + service
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  localizeServiceName(booking.serviceName, AppLocalizations.of(context)!, nameAr: booking.serviceNameAr),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Date/time + status pill (pre-phase) or chevron
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 11,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(
                                    booking.formattedDate,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_outlined,
                                      size: 11,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(
                                    booking.scheduledTime,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              if (!showTracker) ...[
                                const SizedBox(height: 4),
                                _PrePhaseStatusPill(
                                  status: booking.status,
                                  color: _prePhasePillColor(booking.status),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                            size: 18,
                          ),
                        ],
                      ),

                      // ── Phase tracker (only for onTheWay → completed) ──
                      if (showTracker) ...[
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFF0F0F0)),
                        const SizedBox(height: 14),
                        _PhaseProgressTracker(activeIndex: activeIndex),
                        const SizedBox(height: 10),
                        Text(
                          _phases[activeIndex].label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeIndex == 3 && !booking.paymentConfirmed
                              ? 'Tap to review and confirm payment'
                              : _phases[activeIndex].subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phase progress tracker
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseProgressTracker extends StatelessWidget {
  final int activeIndex;

  const _PhaseProgressTracker({required this.activeIndex});

  static const _stepCount = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < _stepCount; i++) ...[
          _StepDot(
            isCompleted: i < activeIndex,
            isCurrent: i == activeIndex,
          ),
          if (i < _stepCount - 1)
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i < activeIndex
                      ? AppColors.primaryOrange
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;

  const _StepDot({required this.isCompleted, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final filled = isCompleted || isCurrent;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primaryOrange : const Color(0xFFE0E0E0),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.38),
                  blurRadius: 8,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : isCurrent
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small pill shown when booking hasn't reached the tracker phases yet
// ─────────────────────────────────────────────────────────────────────────────

class _PrePhaseStatusPill extends StatelessWidget {
  final BookingStatus status;
  final Color color;

  const _PrePhaseStatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
