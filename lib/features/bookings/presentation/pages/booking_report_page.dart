import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';

class BookingReportPage extends StatefulWidget {
  final Booking booking;

  const BookingReportPage({super.key, required this.booking});

  @override
  State<BookingReportPage> createState() => _BookingReportPageState();
}

class _BookingReportPageState extends State<BookingReportPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _showTitleError = false;
  bool _showDescriptionError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _showTitleError = _titleController.text.trim().isEmpty;
      _showDescriptionError = _descriptionController.text.trim().isEmpty;
    });
    return !_showTitleError && !_showDescriptionError;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listener: (context, state) {
        if (state is BookingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully'),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
          // Pop back to My Bookings root
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state is BookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
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

                // Report form card
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
                        'Report an Issue',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Help us improve by reporting problems',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Issue title field
                      _FieldLabel(label: 'Describe the issue'),
                      const SizedBox(height: 8),
                      _ReportTextField(
                        controller: _titleController,
                        hintText: 'e.g. Technician arrived late',
                        maxLines: 1,
                        hasError: _showTitleError,
                        errorText: 'Please describe the issue',
                        onChanged: (_) {
                          if (_showTitleError) {
                            setState(() => _showTitleError = false);
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Details field
                      _FieldLabel(label: 'Provide details'),
                      const SizedBox(height: 8),
                      _ReportTextField(
                        controller: _descriptionController,
                        hintText:
                            'Provide details so our team can investigate.',
                        maxLines: 5,
                        hasError: _showDescriptionError,
                        errorText: 'Please provide details',
                        onChanged: (_) {
                          if (_showDescriptionError) {
                            setState(() => _showDescriptionError = false);
                          }
                        },
                      ),
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
                              final fullDescription =
                                  '${_titleController.text.trim()}\n\n${_descriptionController.text.trim()}';
                              context.read<BookingsBloc>().add(
                                SubmitReportEvent(
                                  bookingId: widget.booking.id,
                                  description: fullDescription,
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
                            'Submit Report',
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
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.edit_outlined,
          color: AppColors.primaryOrange,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

// ─── Text field with error ────────────────────────────────────────────────────

class _ReportTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool hasError;
  final String errorText;
  final ValueChanged<String> onChanged;

  const _ReportTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    required this.hasError,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: hasError
                ? const Color(0xFFFFF3F3)
                : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.error, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: hasError
                  ? const BorderSide(color: AppColors.error, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primaryOrange,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
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
