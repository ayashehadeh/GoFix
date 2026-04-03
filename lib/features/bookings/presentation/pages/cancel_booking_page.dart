import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';

class CancelBookingPage extends StatelessWidget {
  final Booking booking;

  const CancelBookingPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listener: (context, state) {
        if (state is BookingCancelledSuccess) {
          // Pop all booking pages back to My Bookings root
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state is BookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is BookingActionLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.primaryDark),
            title: const Text(
              'Booking Information',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Professional mini card
                      _ProfessionalCard(booking: booking),
                      const SizedBox(height: 16),

                      // Booking details (greyed out, non-interactive)
                      _BookingDetailsSummary(booking: booking),
                      const SizedBox(height: 24),

                      // Cancel confirmation card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
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
                        child: Column(
                          children: [
                            const Text(
                              'Cancel Booking?',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'This action is permanent and cannot be reversed. Your booking will be removed immediately.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Yes, Cancel Booking
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.read<BookingsBloc>().add(
                                              CancelBookingEvent(booking.id),
                                            );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Yes, Cancel Booking',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Keep my Booking
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDark,
                                  side: const BorderSide(
                                      color: AppColors.primaryDark),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  'Keep my Booking',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _ProfessionalCard extends StatelessWidget {
  final Booking booking;

  const _ProfessionalCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE0E8F0),
            backgroundImage: booking.professionalImageUrl != null
                ? NetworkImage(booking.professionalImageUrl!)
                : null,
            child: booking.professionalImageUrl == null
                ? const Icon(Icons.person,
                    color: AppColors.primaryDark, size: 26)
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.professionalName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                booking.professionalRole,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingDetailsSummary extends StatelessWidget {
  final Booking booking;

  const _BookingDetailsSummary({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(icon: Icons.settings, text: booking.serviceName),
          _SummaryRow(
              icon: Icons.calendar_month_outlined,
              text: booking.formattedDate),
          _SummaryRow(
              icon: Icons.access_time_outlined,
              text: booking.scheduledTime),
          _SummaryRow(
              icon: Icons.location_on_outlined, text: booking.address),
          _SummaryRow(
              icon: Icons.attach_money,
              text: booking.servicePrice,
              isLast: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;

  const _SummaryRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
