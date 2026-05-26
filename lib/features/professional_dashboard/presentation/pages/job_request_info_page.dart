import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/professional_dashboard_bloc.dart';
import '../bloc/professional_dashboard_event.dart';
import '../bloc/professional_dashboard_state.dart';
import '../../../professional_jobs/presentation/pages/my_jobs_page.dart';
import '../../../professional_jobs/presentation/bloc/professional_jobs_bloc.dart';
import 'package:gp/injection_container.dart' as di;

class JobRequestInfoPage extends StatefulWidget {
  final JobEntity job;

  const JobRequestInfoPage({super.key, required this.job});

  @override
  State<JobRequestInfoPage> createState() => _JobRequestInfoPageState();
}

class _JobRequestInfoPageState extends State<JobRequestInfoPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionalDashboardBloc, ProfessionalDashboardState>(
      listenWhen: (_, current) => current is RequestActionSuccess || current is RequestActionError,
      listener: (context, state) {
        if (state is RequestActionSuccess) {
          final accepted = state.message.toLowerCase().contains('accept');
          _showResultSheet(context, accepted: accepted);
        }
        if (state is RequestActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is RequestActionLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Color(0xFF062B4D)),
            title: Text(
              AppLocalizations.of(context)!.jobInformation,
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
                _JobDetailsCard(job: widget.job),
                const SizedBox(height: 16),
                _ServiceDescriptionCard(job: widget.job),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Accept Request
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context.read<ProfessionalDashboardBloc>().add(AcceptRequest(widget.job.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(AppLocalizations.of(context)!.acceptRequest,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Decline Request
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => _showDeclineSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF062B4D),
                        side: const BorderSide(color: Color(0xFF062B4D), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(AppLocalizations.of(context)!.declineRequest,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Decline sheet ───────────────────────────────────────────────────────────

  void _showDeclineSheet(BuildContext context) {
    final reasonCtrl = TextEditingController();
    final bloc = context.read<ProfessionalDashboardBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Stack(
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
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 40,
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
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(sheetCtx)!.requestRejected,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF062B4D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(sheetCtx)!.customerNotified,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Reason field
                    Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: Color(0xFFFF8C1A), size: 16),
                        const SizedBox(width: 6),
                        Text(AppLocalizations.of(sheetCtx)!.reasonOptional,
                            style:
                                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF062B4D))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(sheetCtx)!.tellCustomerWhy,
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
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

                    // Done button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetCtx).pop();
                          bloc.add(DeclineRequest(widget.job.id));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C1A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(AppLocalizations.of(sheetCtx)!.done,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result sheet (accept / decline) ────────────────────────────────────────

  void _showResultSheet(BuildContext context, {required bool accepted}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetCtx) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
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
                    margin: const EdgeInsets.only(bottom: 28),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Text(
                    accepted
                        ? AppLocalizations.of(sheetCtx)!.requestAccepted
                        : AppLocalizations.of(sheetCtx)!.requestRejected,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF062B4D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    accepted
                        ? AppLocalizations.of(sheetCtx)!.jobAddedToSchedule
                        : AppLocalizations.of(sheetCtx)!.customerNotified,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
                  ),
                  const SizedBox(height: 28),

                  if (accepted) ...[
                    // Celebration illustration
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF062B4D),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.check_circle_outline, color: Color(0xFFFF8C1A), size: 64),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // View My Jobs button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pop: result sheet + job info page + dashboard
                          Navigator.of(sheetCtx).pop();
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => di.sl<ProfessionalJobsBloc>(),
                                child: const MyJobsPage(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C1A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(AppLocalizations.of(sheetCtx)!.viewMyJobs,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ] else ...[
                    // Decline — just a Done button back to dashboard
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetCtx).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C1A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(AppLocalizations.of(sheetCtx)!.done,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Job details card ─────────────────────────────────────────────────────────

class _JobDetailsCard extends StatelessWidget {
  final JobEntity job;
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
          _Row(icon: Icons.build_outlined, text: job.serviceType),
          _Row(icon: Icons.person_outline, text: job.clientName),
          _Row(
            icon: Icons.calendar_month_outlined,
            text: DateFormat('MMM d, yyyy').format(job.scheduledTime),
          ),
          _Row(
            icon: Icons.access_time_outlined,
            text: DateFormat('h:mm a').format(job.scheduledTime),
          ),
          _Row(icon: Icons.location_on_outlined, text: job.location, isLast: true, onTap: () => _launchMaps(job.location, latitude: job.latitude, longitude: job.longitude)),
        ],
      ),
    );
  }
}

// ─── Service description card ─────────────────────────────────────────────────

class _ServiceDescriptionCard extends StatelessWidget {
  final JobEntity job;
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
          Text(
            (job.description != null && job.description!.isNotEmpty) ? job.description! : 'No description provided.',
            style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
          ),
          if (job.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.image_outlined, color: Color(0xFF062B4D), size: 18),
                const SizedBox(width: 8),
                Text(
                  '${job.imageUrls.length} ${job.imageUrls.length == 1 ? 'picture attached' : 'pictures attached'}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF062B4D), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: job.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    job.imageUrls[index],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
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
                if (onTap != null)
                  const Icon(Icons.open_in_new, size: 13, color: Color(0xFFFF8C1A)),
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
