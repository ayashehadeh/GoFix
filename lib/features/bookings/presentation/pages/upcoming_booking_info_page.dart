import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../professionals/domain/usecases/profeessional_usecases/toggle_favorite.dart';
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
  State<UpcomingBookingInfoPage> createState() =>
      _UpcomingBookingInfoPageState();
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
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is ConfirmPaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.paymentConfirmedMoved),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          if (state is BookingsError) {
            return _ErrorBody(
              message: state.message,
              onRetry: () => context
                  .read<BookingsBloc>()
                  .add(LoadBookingById(widget.bookingId)),
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
                          text: localizeServiceName(booking.serviceName, AppLocalizations.of(context)!, nameAr: booking.serviceNameAr)),
                      _DetailRow(
                          icon: Icons.calendar_month_outlined,
                          text: booking.formattedDate),
                      _DetailRow(
                          icon: Icons.access_time_outlined,
                          text: booking.scheduledTime),
                      _DetailRow(
                          icon: Icons.location_on_outlined,
                          text: booking.address),
                      _DetailRow(
                          icon: Icons.attach_money,
                          text: booking.servicePrice,
                          isLast: true),
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
                      ),
                      if (booking.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.image_outlined,
                                color: AppColors.primaryDark, size: 18),
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
    final awaitingPayment =
        booking.status == BookingStatus.completed && !booking.paymentConfirmed;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: awaitingPayment
          ? SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context
                    .read<BookingsBloc>()
                    .add(ConfirmPaymentEvent(booking.id)),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.confirmPayment,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => di.sl<BookingsBloc>(),
                            child: ModifyBookingPage(booking: booking),
                          ),
                        ),
                      );
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
                      AppLocalizations.of(context)!.modifyBooking,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _IconActionButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<BookingsBloc>(),
                          child: CancelBookingPage(booking: booking),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _IconActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => context.read<ChatBloc>().add(
                        GetOrCreateChatEvent(
                          professionalId: booking.professionalId,
                          professionalName: booking.professionalName,
                        ),
                      ),
                ),
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

class _ProfessionalCard extends StatefulWidget {
  final Booking booking;

  const _ProfessionalCard({required this.booking});

  @override
  State<_ProfessionalCard> createState() => _ProfessionalCardState();
}

class _ProfessionalCardState extends State<_ProfessionalCard> {
  bool _isFavorite = false;

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    final result = await di.sl<ToggleFavorite>()(widget.booking.professionalId);
    result.fold(
      (failure) {
        if (mounted) setState(() => _isFavorite = !_isFavorite);
      },
      (_) {},
    );
  }

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
            backgroundImage: widget.booking.professionalImageUrl != null
                ? NetworkImage(widget.booking.professionalImageUrl!)
                : null,
            child: widget.booking.professionalImageUrl == null
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
                  widget.booking.professionalName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.booking.professionalRole,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleFavorite,
            child: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primaryOrange,
              size: 22,
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
                      fontSize: 14, color: AppColors.primaryDark),
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
          Text(message,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
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
}
