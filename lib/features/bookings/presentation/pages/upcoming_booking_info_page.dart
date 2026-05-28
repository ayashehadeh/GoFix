import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/widgets/fullscreen_image_viewer.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/skeletons/booking_job_detail_skeleton.dart';
import '../../../../injection_container.dart' as di;
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../settings/presentation/bloc/address_bloc.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import 'cancel_booking_page.dart';
import 'modify_booking_page.dart';

class UpcomingBookingInfoPage extends StatefulWidget {
  final String bookingId;

  const UpcomingBookingInfoPage({super.key, required this.bookingId});

  @override
  State<UpcomingBookingInfoPage> createState() => _UpcomingBookingInfoPageState();
}

class _UpcomingBookingInfoPageState extends State<UpcomingBookingInfoPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(LoadBookingById(widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (_) => di.sl<ChatBloc>(),
      child: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatReady) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<ChatBloc>(),
                  child: ChatPage(
                    chatId: state.chat.id,
                    professionalName: state.chat.name,
                  ),
                ),
              ),
            );
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
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
              if (state is BookingCancelledSuccess) {
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/bookings' || route.isFirst,
                );
              }
              if (state is ConfirmPaymentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.paymentConfirmedMoved),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/bookings' || route.isFirst,
                );
              }
              if (state is ConfirmPaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is BookingsLoading) {
                return const BookingJobDetailSkeleton();
              }

              if (state is BookingsError) {
                return _ErrorBody(
                  message: state.message,
                  onRetry: () => context.read<BookingsBloc>().add(LoadBookingById(widget.bookingId)),
                );
              }

              if (state is BookingDetailLoaded) {
                return _UpcomingInfoBody(booking: state.booking);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _UpcomingInfoBody extends StatelessWidget {
  final Booking booking;

  const _UpcomingInfoBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Professional card with favourite icon
                _ProfessionalCard(booking: booking),
                const SizedBox(height: 16),

                // Booking details card
                _SectionCard(
                  title: AppLocalizations.of(context)!.bookingDetails,
                  child: Column(
                    children: [
                      _DetailRow(
                          icon: Icons.settings,
                          text: localizeServiceName(booking.serviceName, AppLocalizations.of(context)!,
                              nameAr: booking.serviceNameAr)),
                      _DetailRow(icon: Icons.calendar_month_outlined, text: booking.formattedDate),
                      _DetailRow(icon: Icons.access_time_outlined, text: booking.scheduledTime),
                      _DetailRow(
                          icon: Icons.location_on_outlined,
                          text: booking.address,
                          onTap: () =>
                              _launchMaps(booking.address, latitude: booking.latitude, longitude: booking.longitude)),
                      _DetailRow(icon: Icons.attach_money, text: booking.servicePrice, isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Service description card
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
                      ), // AFTER — in upcoming_booking_info_page.dart
                      if (booking.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.image_outlined, color: AppColors.primaryDark, size: 18),
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
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: booking.imageUrls.asMap().entries.map((entry) {
                            final index = entry.key;
                            final url = entry.value;
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullscreenImageViewer(
                                    imageUrls: booking.imageUrls,
                                    initialIndex: index,
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 28),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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

        // Bottom action bar
        _BottomActionBar(booking: booking),
      ],
    );
  }
}

// ─── Bottom action bar ────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final Booking booking;

  const _BottomActionBar({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isCompleted = booking.status == BookingStatus.completed;
    final waitingForAmount = isCompleted && !booking.paymentConfirmed && !booking.professionalConfirmedPayment;
    final canConfirm = isCompleted && !booking.paymentConfirmed && booking.professionalConfirmedPayment;

    if (waitingForAmount) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: AppColors.primaryOrange, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Waiting for professional to set the payment amount...',
                  style: TextStyle(fontSize: 13.5, color: AppColors.primaryOrange, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (canConfirm) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agreed Amount',
                    style: TextStyle(fontSize: 14, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${booking.agreedAmount!.toStringAsFixed(2)} JD',
                    style: const TextStyle(fontSize: 18, color: AppColors.primaryOrange, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.read<BookingsBloc>().add(ConfirmPaymentEvent(booking.id)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.confirmPayment,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      );
    }

    void goToCancel() => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<BookingsBloc>(),
              child: CancelBookingPage(booking: booking),
            ),
          ),
        );

    void goToChat() => context.read<ChatBloc>().add(
          GetOrCreateChatEvent(
            professionalId: booking.professionalId,
            professionalName: booking.professionalName,
          ),
        );

    final isPending = booking.status == BookingStatus.pending;
    final isCancellable = isPending ||
        booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.accepted;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Row(
        children: [
          if (isPending) ...[
            // Modify + cancel icon + chat icon
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (_) => di.sl<BookingsBloc>()),
                          BlocProvider(create: (_) => di.sl<AddressBloc>()),
                        ],
                        child: ModifyBookingPage(booking: booking),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.modifyBooking,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _IconActionButton(icon: Icons.delete_outline_rounded, onTap: goToCancel),
            const SizedBox(width: 10),
            _IconActionButton(icon: Icons.chat_bubble_outline_rounded, onTap: goToChat),
          ] else if (isCancellable) ...[
            // Cancel button (full-width) + chat icon
            Expanded(
              child: OutlinedButton(
                onPressed: goToCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.primaryDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.cancelBooking,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _IconActionButton(icon: Icons.chat_bubble_outline_rounded, onTap: goToChat),
          ] else ...[
            // inProgress and beyond — chat only (full-width)
            Expanded(
              child: OutlinedButton(
                onPressed: goToChat,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.primaryDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Chat with Professional',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryDark, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryDark, size: 22),
      ),
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
            backgroundImage:
                booking.professionalImageUrl != null ? NetworkImage(booking.professionalImageUrl!) : null,
            child: booking.professionalImageUrl == null
                ? const Icon(Icons.person, color: AppColors.primaryDark, size: 28)
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
        ],
      ),
    );
  }
}

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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.text,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryOrange, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryDark,
                      decoration: onTap != null ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                if (onTap != null) const Icon(Icons.open_in_new, size: 14, color: AppColors.primaryOrange),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}

Future<void> _launchMaps(String address, {double? latitude, double? longitude}) async {
  final uri = (latitude != null && longitude != null)
      ? Uri.parse('https://www.google.com/maps/?q=$latitude,$longitude')
      : Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
