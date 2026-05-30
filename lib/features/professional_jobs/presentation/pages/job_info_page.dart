import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/utils/snackbar_helper.dart';
import 'package:gp/core/widgets/cancel_reason_dialog.dart';
import 'package:gp/core/widgets/fullscreen_image_viewer.dart';
import 'package:gp/core/widgets/payment_amount_sheet.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/l10n/service_name_l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/professional_jobs_bloc.dart';
import '../bloc/professional_jobs_event.dart';
import '../bloc/professional_jobs_state.dart';
import '../../domain/entities/pro_job.dart';

class JobInfoPage extends StatelessWidget {
  final ProJob job;

  const JobInfoPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfessionalJobsBloc, ProfessionalJobsState>(
      listener: (context, state) {
        if (state is JobStatusUpdateSuccess) {
          Navigator.of(context).pop(); // return to MyJobsPage
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Color(0xFF062B4D)),
          title: Builder(
            builder: (ctx) => Text(
              AppLocalizations.of(ctx)!.jobDetails,
              style: const TextStyle(
                color: Color(0xFF062B4D),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _JobDetailsCard(job: job),
              const SizedBox(height: 16),
              _ServiceDescriptionCard(job: job),
            ],
          ),
        ),
        bottomNavigationBar: job.status.isActive ? _BottomActions(job: job) : null,
      ),
    );
  }
}

// ─── Job details card ─────────────────────────────────────────────────────────

class _JobDetailsCard extends StatelessWidget {
  final ProJob job;
  const _JobDetailsCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.jobDetails,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF062B4D))),
          const SizedBox(height: 12),
          _Row(icon: Icons.build_outlined, text: localizeServiceName(job.serviceType, AppLocalizations.of(context)!, nameAr: job.serviceTypeAr)),
          _Row(icon: Icons.person_outline, text: job.clientName),
          if ((job.status == ProJobStatus.arrived || job.status == ProJobStatus.inProgress) &&
              job.clientPhone != null &&
              job.clientPhone!.isNotEmpty)
            _Row(
              icon: Icons.phone_outlined,
              text: job.clientPhone!,
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: job.clientPhone);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
            ),
          _Row(icon: Icons.calendar_month_outlined, text: job.formattedDate),
          _Row(icon: Icons.access_time_outlined, text: job.formattedTime),
          _Row(
            icon: Icons.location_on_outlined,
            text: job.location,
            onTap: () => _launchMaps(job.location, latitude: job.latitude, longitude: job.longitude),
          ),
          _Row(
            icon: Icons.attach_money,
            text: job.agreedAmount != null ? '${job.agreedAmount!.toStringAsFixed(2)} JD' : job.price,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─── Service description card ─────────────────────────────────────────────────

class _ServiceDescriptionCard extends StatelessWidget {
  final ProJob job;
  const _ServiceDescriptionCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_outlined, color: Color(0xFFFF8C1A), size: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.serviceDescription,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF062B4D))),
            ],
          ),
          const SizedBox(height: 10),
          Text(job.description, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.6)),
          // AFTER — in job_info_page.dart
          if (job.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.image_outlined, color: Color(0xFF062B4D), size: 18),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.picturesAttached(job.imageUrls.length),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF062B4D)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.imageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImageViewer(
                        imageUrls: job.imageUrls,
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
    );
  }
}

// ─── Bottom actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final ProJob job;
  const _BottomActions({required this.job});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _showStatusSheet(context, pageContext: context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context)!.updateStatus,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              width: 50,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: navigate to chat
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF062B4D), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF062B4D), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context, {required BuildContext pageContext}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<ProfessionalJobsBloc>(),
        child: _StatusSheet(job: job, pageContext: pageContext),
      ),
    );
  }
}

// ─── Status update sheet ──────────────────────────────────────────────────────

class _StatusSheet extends StatefulWidget {
  final ProJob job;
  final BuildContext pageContext;
  const _StatusSheet({required this.job, required this.pageContext});

  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  ProJobStatus? _selected;

  Set<ProJobStatus> _allowedStatuses(ProJobStatus current) => switch (current) {
        ProJobStatus.pending => {ProJobStatus.onTheWay, ProJobStatus.cancelled},
        ProJobStatus.confirmed => {ProJobStatus.onTheWay, ProJobStatus.cancelled},
        ProJobStatus.onTheWay => {ProJobStatus.arrived, ProJobStatus.cancelled},
        ProJobStatus.arrived => {ProJobStatus.inProgress, ProJobStatus.cancelled},
        ProJobStatus.inProgress => {ProJobStatus.completed, ProJobStatus.cancelled},
        _ => {},
      };

  List<_StatusOption> _buildOptions(AppLocalizations l10n) => [
        _StatusOption(
          status: ProJobStatus.onTheWay,
          title: l10n.statusOnTheWay,
          subtitle: "Let the customer know you're heading over.",
          icon: Icons.directions_car_outlined,
        ),
        _StatusOption(
          status: ProJobStatus.arrived,
          title: l10n.statusArrived,
          subtitle: "You're at the client's location.",
          icon: Icons.place_outlined,
        ),
        _StatusOption(
          status: ProJobStatus.inProgress,
          title: l10n.statusInProgress,
          subtitle: "You've started the job.",
          icon: Icons.settings_outlined,
        ),
        _StatusOption(
          status: ProJobStatus.completed,
          title: l10n.statusCompleted,
          subtitle: "The job is done successfully.",
          icon: Icons.check_circle_outline,
        ),
        _StatusOption(
          status: ProJobStatus.cancelled,
          title: l10n.cancelBooking,
          subtitle: "Only use if the job can't be completed.",
          icon: Icons.cancel_outlined,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionalJobsBloc, ProfessionalJobsState>(
      listener: (ctx, state) {
        if (state is JobStatusUpdateSuccess) {
          Navigator.of(ctx).pop(); // close sheet
        }
        if (state is ProfessionalJobsError) {
          Navigator.of(ctx).pop();
          showErrorSnackbar(ctx, state.message);
        }
      },
      builder: (ctx, state) {
        final isLoading = state is JobStatusUpdateLoading;

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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(AppLocalizations.of(ctx)!.jobStatus,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF062B4D),
                        )),
                    const SizedBox(height: 20),

                    // Status options
                    ..._buildOptions(AppLocalizations.of(ctx)!).map((opt) {
                      final allowed = _allowedStatuses(widget.job.status);
                      final isEnabled = allowed.contains(opt.status);
                      return _StatusTile(
                        option: opt,
                        isSelected: _selected == opt.status,
                        isEnabled: isEnabled,
                        onTap: isEnabled ? () => setState(() => _selected = opt.status) : () {},
                      );
                    }),
                    const SizedBox(height: 16),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_selected == null || isLoading)
                            ? null
                            : () {
                                if (_selected == ProJobStatus.completed) {
                                  Navigator.of(ctx).pop();
                                  showPaymentAmountSheet(
                                    widget.pageContext,
                                    jobId: widget.job.id,
                                    onSuccess: () {
                                      if (widget.pageContext.mounted) {
                                        Navigator.of(widget.pageContext).pop();
                                      }
                                    },
                                  );
                                } else if (_selected == ProJobStatus.cancelled) {
                                  showCancelReasonDialog(ctx, onConfirm: (reason) {
                                    ctx.read<ProfessionalJobsBloc>().add(
                                      CancelProJobEvent(jobId: widget.job.id, reason: reason),
                                    );
                                  });
                                } else {
                                  ctx.read<ProfessionalJobsBloc>().add(UpdateProJobStatusEvent(
                                        jobId: widget.job.id,
                                        newStatus: _selected!,
                                      ));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C1A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(AppLocalizations.of(ctx)!.confirmUpdate,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

class _StatusOption {
  final ProJobStatus status;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StatusOption({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _StatusTile extends StatelessWidget {
  final _StatusOption option;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _StatusTile({
    required this.option,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  Color get _iconColor {
    if (option.status == ProJobStatus.cancelled) return Colors.grey;
    return const Color(0xFFFF8C1A);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: isEnabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF8C1A) : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(option.icon, color: _iconColor, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF062B4D))),
                      const SizedBox(height: 3),
                      Text(option.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFF8C1A), size: 20),
              ],
            ),
          ),
        ));
  }
}

// ─── Detail row ───────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;
  final VoidCallback? onTap;
  const _Row({required this.icon, required this.text, this.isLast = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF8C1A), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF062B4D),
                      decoration: onTap != null ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                if (onTap != null) const Icon(Icons.open_in_new, size: 13, color: Color(0xFFFF8C1A)),
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
