import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
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
    return BlocProvider(
      create: (_) => di.sl<ProfessionalsBloc>(),
      child: BlocConsumer<ProfessionalsBloc, ProfessionalsState>(
        listener: (context, state) {
          if (state is ReviewActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Review submitted successfully'),
                backgroundColor: AppColors.primaryOrange,
              ),
            );
            // Pop back to My Bookings (pop twice: review page + feedback page)
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Professional mini card
                  _ProfessionalMiniCard(booking: widget.booking),
                  const SizedBox(height: 16),

                  // Booking details summary
                  _BookingDetailsSummary(booking: widget.booking),
                  const SizedBox(height: 16),

                  // Review form card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'How was the service?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Star rating
                        _StarRatingRow(
                          selectedStars: _selectedStars,
                          onStarTap: (star) {
                            setState(() {
                              _selectedStars = star;
                              _showStarError = false;
                            });
                          },
                        ),
                        if (_showStarError) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Please select a rating',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Comment field
                        _CommentField(controller: _commentController),
                      ],
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
                          borderRadius: BorderRadius.circular(12),
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
                          : const Text(
                              'Submit Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Star rating row ──────────────────────────────────────────────────────────

class _StarRatingRow extends StatelessWidget {
  final int selectedStars;
  final ValueChanged<int> onStarTap;

  const _StarRatingRow({required this.selectedStars, required this.onStarTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        final isFilled = star <= selectedStars;
        return GestureDetector(
          onTap: () => onStarTap(star),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.primaryOrange,
              size: 38,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Comment field ────────────────────────────────────────────────────────────

class _CommentField extends StatelessWidget {
  final TextEditingController controller;

  const _CommentField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8, top: 12),
          child: Icon(
            Icons.edit_outlined,
            color: AppColors.primaryOrange,
            size: 18,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(),
        hintText: 'Write your feedback (optional)',
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
    );
  }
}

// ─── Reused sub-widgets ───────────────────────────────────────────────────────

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
            text: booking.formattedDate,
          ),
          _SummaryRow(
            icon: Icons.access_time_outlined,
            text: booking.scheduledTime,
          ),
          _SummaryRow(
            icon: Icons.location_on_outlined,
            text: booking.address,
            isLast: true,
          ),
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
