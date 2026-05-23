import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import 'booking_feedback_page.dart';

class BookingInfoPage extends StatefulWidget {
  final String bookingId;

  const BookingInfoPage({super.key, required this.bookingId});

  @override
  State<BookingInfoPage> createState() => _BookingInfoPageState();
}

class _BookingInfoPageState extends State<BookingInfoPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(LoadBookingById(widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: Builder(
          builder: (ctx) => Text(
            AppLocalizations.of(ctx)!.bookingDetails,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, state) {
          if (state is ConfirmPaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.paymentConfirmed)),
            );
            context.read<BookingsBloc>().add(LoadBookingById(widget.bookingId));
          } else if (state is ConfirmPaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingsLoading || state is BookingActionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          if (state is BookingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BookingsBloc>()
                        .add(LoadBookingById(widget.bookingId)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalizations.of(context)!.retry,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is BookingDetailLoaded) {
            return _BookingInfoBody(booking: state.booking);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _BookingInfoBody extends StatelessWidget {
  final Booking booking;

  const _BookingInfoBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Professional card
                _ProfessionalCard(booking: booking),
                const SizedBox(height: 16),

                // Booking details
                _SectionCard(
                  title: AppLocalizations.of(context)!.bookingDetails,
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.settings,
                        text: localizeServiceName(booking.serviceName, AppLocalizations.of(context)!, nameAr: booking.serviceNameAr),
                      ),
                      _DetailRow(
                        icon: Icons.calendar_month_outlined,
                        text: booking.formattedDate,
                      ),
                      _DetailRow(
                        icon: Icons.access_time_outlined,
                        text: booking.scheduledTime,
                      ),
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        text: booking.address,
                      ),
                      _DetailRow(
                        icon: Icons.attach_money,
                        text: booking.servicePrice,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Service description
                _SectionCard(
                  title: AppLocalizations.of(context)!.serviceDescription,
                  titleIcon: Icons.edit_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A4A4A),
                          height: 1.6,
                        ),
                      ),
                      if (booking.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              color: AppColors.primaryDark,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${booking.imageUrls.length} ${booking.imageUrls.length == 1 ? AppLocalizations.of(context)!.pictureAttachedSingular : AppLocalizations.of(context)!.picturesAttachedPlural}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Bottom action buttons — only show for past bookings
        if (booking.isPast) _BottomActions(booking: booking),
      ],
    );
  }
}

// ─── Professional card ────────────────────────────────────────────────────────

class _ProfessionalCard extends StatelessWidget {
  final Booking booking;

  const _ProfessionalCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE0E8F0),
            backgroundImage: booking.professionalImageUrl != null
                ? NetworkImage(booking.professionalImageUrl!)
                : null,
            child: booking.professionalImageUrl == null
                ? const Icon(Icons.person,
                    color: AppColors.primaryDark, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.professionalName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  booking.professionalRole,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (booking.isPast)
            GestureDetector(
              onTap: () {
                // TODO: toggle favourite
              },
              child: const Icon(
                Icons.favorite_border,
                color: AppColors.primaryOrange,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Generic section card ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.titleIcon,
    required this.child,
  });

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
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, color: AppColors.primaryOrange, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Detail row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryDark,
                  ),
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

// ─── Bottom actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final Booking booking;

  const _BottomActions({required this.booking});

  @override
  Widget build(BuildContext context) {
    final showConfirmPayment =
        booking.status == BookingStatus.completed && !booking.paymentConfirmed;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showConfirmPayment) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context
                    .read<BookingsBloc>()
                    .add(ConfirmPaymentEvent(booking.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.confirmPayment,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back and trigger re-booking with same professional
                    Navigator.pop(context);
                    // TODO: Navigate to booking flow with professionalId pre-filled
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.bookService,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<BookingsBloc>(),
                          child: BookingFeedbackPage(booking: booking),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(0, 50),
                    side: const BorderSide(color: AppColors.primaryDark),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.writeReview,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
