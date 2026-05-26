import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import '../../../../injection_container.dart' as di;
import '../../../professionals/domain/usecases/review_usecases/add_review.dart';
import '../../domain/entities/booking.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';

enum _Sheet { choose, review, report }

class BookingFeedbackPage extends StatefulWidget {
  final Booking booking;
  const BookingFeedbackPage({super.key, required this.booking});

  @override
  State<BookingFeedbackPage> createState() => _BookingFeedbackPageState();
}

class _BookingFeedbackPageState extends State<BookingFeedbackPage> {
  bool _sheetOpen = false;

  // BookingsBloc reused across sheets
  late final BookingsBloc _bookingsBloc = context.read<BookingsBloc>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _openSheet(_Sheet.choose));
  }

  void _goBackWithSnackbar(String message) {
    // Pop BookingFeedbackPage → BookingInfoPage → land on MyBookingsPage
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF8C1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _openSheet(_Sheet sheet) {
    if (_sheetOpen) return;
    _sheetOpen = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: sheet == _Sheet.choose,
      enableDrag: sheet == _Sheet.choose,
      builder: (sheetCtx) {
        switch (sheet) {
          case _Sheet.choose:
            return _ChooseSheet(
              onReviewChosen: () => Navigator.of(sheetCtx).pop('review'),
              onReportChosen: () => Navigator.of(sheetCtx).pop('report'),
            );
          case _Sheet.review:
            return _ReviewSheet(
              booking: widget.booking,
              onSuccess: () => Navigator.of(sheetCtx).pop('review_done'),
            );
          case _Sheet.report:
            return BlocProvider.value(
              value: _bookingsBloc,
              child: _ReportSheet(
                booking: widget.booking,
                onSuccess: () => Navigator.of(sheetCtx).pop('report_done'),
              ),
            );
        }
      },
    ).then((result) {
      _sheetOpen = false;
      if (!mounted) return;

      if (result == 'review') {
        _openSheet(_Sheet.review);
      } else if (result == 'report') {
        _openSheet(_Sheet.report);
      } else if (result == 'review_done') {
        _goBackWithSnackbar(AppLocalizations.of(context)!.reviewSubmittedSuccess);
      } else if (result == 'report_done') {
        _goBackWithSnackbar(AppLocalizations.of(context)!.reportSubmittedSuccess);
      } else {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF062B4D)),
        title: Text(
          AppLocalizations.of(context)!.bookingInformation,
          style: const TextStyle(
            color: Color(0xFF062B4D),
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

// ─── Sheet 1 — Choose ─────────────────────────────────────────────────────────

class _ChooseSheet extends StatelessWidget {
  final VoidCallback onReviewChosen;
  final VoidCallback onReportChosen;
  const _ChooseSheet(
      {required this.onReviewChosen, required this.onReportChosen});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Handle(),
                Text(t.leaveFeedback,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF062B4D))),
                const SizedBox(height: 8),
                Text(t.whatWouldYouDo,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 32),
                _PrimaryBtn(label: t.writeReview, onTap: onReviewChosen),
                const SizedBox(height: 14),
                _OutlineBtn(label: t.reportAnIssue, onTap: onReportChosen),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sheet 2 — Write a Review ─────────────────────────────────────────────────

class _ReviewSheet extends StatefulWidget {
  final Booking booking;
  final VoidCallback onSuccess;
  const _ReviewSheet({required this.booking, required this.onSuccess});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _stars = 0;
  bool _starError = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool _submitting = false;

  Future<void> _submit(BuildContext context) async {
    if (_stars == 0) {
      setState(() => _starError = true);
      return;
    }
    setState(() => _submitting = true);

    final result = await di.sl<AddReview>()(
      professionalId: widget.booking.professionalId,
      bookingId: widget.booking.id,
      rating: _stars.toDouble(),
      comment: _ctrl.text.trim(),
    );

    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      },
      (_) => widget.onSuccess(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = _submitting;
    final t = AppLocalizations.of(context)!;
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
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
                  _Handle(),
                  Text(t.writeReview,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF062B4D))),
                  const SizedBox(height: 6),
                  Text(t.howWasService,
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    children: List.generate(5, (i) {
                      final s = i + 1;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _stars = s;
                          _starError = false;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            s <= _stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFFF8C1A),
                            size: 38,
                          ),
                        ),
                      );
                    }),
                  ),
                  if (_starError) ...[
                    const SizedBox(height: 6),
                    Text(t.selectRatingError,
                        style: const TextStyle(fontSize: 12, color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ctrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8, top: 12),
                        child: Icon(Icons.edit_outlined,
                            color: Color(0xFFFF8C1A), size: 18),
                      ),
                      prefixIconConstraints: const BoxConstraints(),
                      hintText: t.writeFeedbackHint,
                      hintStyle:
                          const TextStyle(fontSize: 13, color: Colors.grey),
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
                  _PrimaryBtn(
                    label: t.submitReview,
                    loading: loading,
                    onTap: () => _submit(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sheet 3 — Report an Issue ────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  final Booking booking;
  final VoidCallback onSuccess;
  const _ReportSheet({required this.booking, required this.onSuccess});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _title = TextEditingController();
  final _details = TextEditingController();
  bool _titleErr = false;
  bool _detailsErr = false;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleErr = _title.text.trim().isEmpty;
      _detailsErr = _details.text.trim().isEmpty;
    });
    return !_titleErr && !_detailsErr;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listener: (ctx, state) {
        if (state is BookingActionSuccess) widget.onSuccess();
        if (state is BookingsError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (ctx, state) {
        final loading = state is BookingActionLoading;
        final t = AppLocalizations.of(ctx)!;
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
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
                      _Handle(),
                      Text(t.reportAnIssue,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF062B4D))),
                      const SizedBox(height: 6),
                      Text(t.reportHelpText,
                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 24),
                      _FieldLabel(t.describeIssue),
                      const SizedBox(height: 8),
                      _ReportField(
                        ctrl: _title,
                        hint: t.issueTitleHint,
                        maxLines: 1,
                        hasError: _titleErr,
                        errText: t.describeIssueError,
                        onChange: (_) {
                          if (_titleErr) setState(() => _titleErr = false);
                        },
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel(t.provideDetails),
                      const SizedBox(height: 8),
                      _ReportField(
                        ctrl: _details,
                        hint: t.provideDetailsHint,
                        maxLines: 4,
                        hasError: _detailsErr,
                        errText: t.provideDetailsError,
                        onChange: (_) {
                          if (_detailsErr) setState(() => _detailsErr = false);
                        },
                      ),
                      const SizedBox(height: 24),
                      _PrimaryBtn(
                        label: t.submitReport,
                        loading: loading,
                        onTap: () {
                          if (_validate()) {
                            ctx.read<BookingsBloc>().add(SubmitReportEvent(
                                  bookingId: widget.booking.id,
                                  description:
                                      '${_title.text.trim()}\n\n${_details.text.trim()}',
                                ));
                          }
                        },
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

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _PrimaryBtn(
      {required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C1A),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      );
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF062B4D),
            side: const BorderSide(color: Color(0xFF062B4D), width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.edit_outlined, color: Color(0xFFFF8C1A), size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF062B4D))),
        ],
      );
}

class _ReportField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final bool hasError;
  final String errText;
  final ValueChanged<String> onChange;
  const _ReportField({
    required this.ctrl,
    required this.hint,
    required this.maxLines,
    required this.hasError,
    required this.errText,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            onChanged: onChange,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              filled: true,
              fillColor:
                  hasError ? const Color(0xFFFFF3F3) : const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: hasError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: hasError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 4),
            Text(errText,
                style: const TextStyle(fontSize: 12, color: Colors.red)),
          ],
        ],
      );
}

// ─── Background page widgets ──────────────────────────────────────────────────

class _ProfessionalMiniCard extends StatelessWidget {
  final Booking booking;
  const _ProfessionalMiniCard({required this.booking});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
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
                  ? const Icon(Icons.person, color: Color(0xFF062B4D), size: 26)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.professionalName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF062B4D))),
                const SizedBox(height: 2),
                Text(booking.professionalRole,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      );
}

class _BookingDetailsSummary extends StatelessWidget {
  final Booking booking;
  const _BookingDetailsSummary({required this.booking});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.bookingDetails,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF062B4D))),
            const SizedBox(height: 12),
            _DR(icon: Icons.settings, text: localizeServiceName(booking.serviceName, AppLocalizations.of(context)!, nameAr: booking.serviceNameAr)),
            _DR(
                icon: Icons.calendar_month_outlined,
                text: booking.formattedDate),
            _DR(icon: Icons.access_time_outlined, text: booking.scheduledTime),
            _DR(
                icon: Icons.location_on_outlined,
                text: booking.address,
                isLast: true),
          ],
        ),
      );
}

class _DR extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;
  const _DR({required this.icon, required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF8C1A), size: 18),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(text,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF062B4D)))),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, color: Color(0xFFF0F0F0)),
        ],
      );
}
