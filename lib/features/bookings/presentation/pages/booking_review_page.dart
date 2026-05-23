import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/service_name_l10n.dart';
import '../../../professionals/presentation/bloc/professionals_bloc.dart';
import '../../../professionals/presentation/bloc/professionals_event.dart';
import '../../../professionals/presentation/bloc/professionals_state.dart';
import '../../domain/entities/booking.dart';

class BookingReviewPage extends StatefulWidget {
  final Booking booking;

  const BookingReviewPage({super.key, required this.booking});

  @override
  State<BookingReviewPage> createState() => _BookingReviewPageState();
}

class _BookingReviewPageState extends State<BookingReviewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showReviewSheet());
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (sheetContext) {
        return BlocProvider(
          create: (_) => di.sl<ProfessionalsBloc>(),
          child: _ReviewSheet(booking: widget.booking),
        );
      },
    ).then((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: Text(
          AppLocalizations.of(context)!.bookingInformation,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfessionalMiniCard(booking: widget.booking),
            const SizedBox(height: 16),
            _BookingDetailsSummary(booking: widget.booking),
          ],
        ),
      ),
    );
  }
}

// ─── Review bottom sheet (has its own BlocConsumer) ───────────────────────────

class _ReviewSheet extends StatefulWidget {
  final Booking booking;
  const _ReviewSheet({required this.booking});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _selectedStars = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _showStarError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() => _showStarError = _selectedStars == 0);
    return _selectedStars > 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocConsumer<ProfessionalsBloc, ProfessionalsState>(
      listener: (context, state) {
        if (state is ReviewActionSuccess) {
          Navigator.of(context).pop(); // close sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.reviewSubmittedSuccess),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
          // pop all the way back to My Bookings
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state is ProfessionalsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfessionalsLoading;

        return Stack(
          children: [
            // ── Blurred + dimmed backdrop ──────────────────────────────────
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),

            // ── Sheet ──────────────────────────────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 28,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Text(
                        t.writeReview,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.howWasService,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stars
                      Row(
                        children: List.generate(5, (i) {
                          final star = i + 1;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedStars = star;
                              _showStarError = false;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                star <= _selectedStars
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: AppColors.primaryOrange,
                                size: 38,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_showStarError) ...[
                        const SizedBox(height: 6),
                        Text(
                          t.selectRatingError,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Comment field
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(
                              left: 12,
                              right: 8,
                              top: 12,
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: AppColors.primaryOrange,
                              size: 18,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(),
                          hintText: t.writeYourFeedback,
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_validate()) {
                                    context.read<ProfessionalsBloc>().add(
                                      AddReviewEvent(
                                        professionalId:
                                            widget.booking.professionalId,
                                        bookingId: widget.booking.id,
                                        rating: _selectedStars.toDouble(),
                                        comment: _commentController.text.trim(),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  t.submitReview,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _ProfessionalMiniCard extends StatelessWidget {
  final Booking booking;
  const _ProfessionalMiniCard({required this.booking});

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
                ? const Icon(
                    Icons.person,
                    color: AppColors.primaryDark,
                    size: 26,
                  )
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
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
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
    final t = AppLocalizations.of(context)!;
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
          Text(
            t.bookingDetails,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _Row(icon: Icons.settings, text: localizeServiceName(booking.serviceName, t, nameAr: booking.serviceNameAr)),
          _Row(
            icon: Icons.calendar_month_outlined,
            text: booking.formattedDate,
          ),
          _Row(icon: Icons.access_time_outlined, text: booking.scheduledTime),
          _Row(
            icon: Icons.location_on_outlined,
            text: booking.address,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;
  const _Row({required this.icon, required this.text, this.isLast = false});

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
                    fontSize: 13,
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
