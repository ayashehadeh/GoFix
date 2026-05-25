import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professional_dashboard/presentation/pages/job_request_info_page.dart';
import 'package:gp/features/professional_jobs/presentation/bloc/professional_jobs_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/features/professional_jobs/presentation/pages/my_jobs_page.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/professional_dashboard_bloc.dart';
import '../bloc/professional_dashboard_event.dart';
import '../bloc/professional_dashboard_state.dart';
import '../../../professional_availability/presentation/bloc/availability_bloc.dart';
import '../../../professional_availability/presentation/pages/my_availability_screen.dart';
import '../../../earnings/presentation/bloc/earnings_bloc.dart';
import '../../../earnings/presentation/pages/earnings_page.dart';
import '../../../../core/widgets/gofix_bottom_nav_bar.dart';
import '../../../../injection_container.dart' as di;
import 'package:gp/core/utils/user_info_helper.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/pages/professional_my_profile_page.dart';
import 'dart:ui';

class ProfessionalDashboardScreen extends StatefulWidget {
  const ProfessionalDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalDashboardScreen> createState() => _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState extends State<ProfessionalDashboardScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalDashboardBloc>().add(LoadDashboard());
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await UserInfoHelper.getFullName();
    if (mounted) setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: BlocConsumer<ProfessionalDashboardBloc, ProfessionalDashboardState>(
          buildWhen: (prev, curr) =>
              curr is DashboardInitial || curr is DashboardLoading || curr is DashboardLoaded || curr is DashboardError,
          listener: (context, state) {
            if (state is RequestActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is RequestActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProfessionalDashboardBloc>().add(RefreshDashboard()),
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderAndStats(context, state),
                      const SizedBox(height: 24),
                      _buildScheduledJobsSection(state),
                      const SizedBox(height: 24),
                      _buildIncomingRequestsSection(state),
                      const SizedBox(height: 24),
                      _buildMenuItems(context),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
      bottomNavigationBar: GoFixBottomNavBar(
        currentIndex: 3,
        showDashboard: true,
        onTap: (index) {
          if (index == 0) Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          if (index == 1) Navigator.of(context).pushNamedAndRemoveUntil('/bookings', (route) => false);
          if (index == 2) Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false);
          if (index == 3) return;
        },
      ),
    );
  }

  Widget _buildHeaderAndStats(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A5C),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${_getTimeOfDay(AppLocalizations.of(context)!)}, $_userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2D4A6B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('${state.stats.requestsCount}', AppLocalizations.of(context)!.totalRequests),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                  _buildStatCard('${state.stats.scheduledCount}', AppLocalizations.of(context)!.scheduled),
                  Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                  _buildStatCard('${state.stats.completedCount}', AppLocalizations.of(context)!.completedJobs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay(AppLocalizations t) {
    final hour = DateTime.now().hour;
    return hour < 12 ? t.goodMorning : t.goodEvening;
  }

  Widget _buildStatCard(String count, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildScheduledJobsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.scheduledJobsTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C))),
              if (state.scheduledJobs.isNotEmpty)
                TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.seeAll)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: state.scheduledJobs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(AppLocalizations.of(context)!.noScheduledJobsYet,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.scheduledJobs.length,
                  itemBuilder: (context, index) => _buildScheduledJobCard(state.scheduledJobs[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildScheduledJobCard(JobEntity job) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1A3A5C),
                child: Text(job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.clientName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(job.serviceType,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(job.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 15, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(DateFormat('MMM d, h:mm a').format(job.scheduledTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showStatusUpdateDialog(job.id, job.status),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE87722),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(AppLocalizations.of(context)!.updateStatus,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.incomingRequestsTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C))),
              if (state.incomingRequests.isNotEmpty)
                TextButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.seeAll)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: state.incomingRequests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(AppLocalizations.of(context)!.noIncomingRequests,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.incomingRequests.length,
                  itemBuilder: (context, index) => _buildRequestCard(state.incomingRequests[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(JobEntity request) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ProfessionalDashboardBloc>(),
              child: JobRequestInfoPage(job: request),
            ),
          ),
        ).then((_) {
          if (context.mounted) {
            context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
          }
        });
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1A3A5C),
                  child: Text(request.clientName.isNotEmpty ? request.clientName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(request.serviceType, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(request.location,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d, h:mm a').format(request.scheduledTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<ProfessionalDashboardBloc>().add(DeclineRequest(request.id)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.of(context)!.declineLabel, style: const TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<ProfessionalDashboardBloc>().add(AcceptRequest(request.id)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE87722),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(AppLocalizations.of(context)!.acceptLabel, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(AppLocalizations.of(context)!.myAvailability, Icons.schedule, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<AvailabilityBloc>(),
                  child: const MyAvailabilityScreen(),
                ),
              ),
            );
          }),
          _buildMenuItem(AppLocalizations.of(context)!.myJobs, Icons.work_outline, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<ProfessionalJobsBloc>(),
                  child: const MyJobsPage(),
                ),
              ),
            );
          }),
          _buildMenuItem(AppLocalizations.of(context)!.myProfile, Icons.person_outline, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<ProfessionalsBloc>(),
                  child: const ProfessionalMyProfilePage(),
                ),
              ),
            );
          }),
          _buildMenuItem(AppLocalizations.of(context)!.myEarnings, Icons.attach_money, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<EarningsBloc>(),
                  child: const EarningsPage(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1A3A5C)),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(String jobId, JobStatus currentStatus) {
    // All five, always shown.
    final options = <String, String>{
      'OnTheWay': 'On The Way',
      'Arrived': 'Arrived',
      'InProgress': 'In Progress',
      'Completed': 'Completed',
      'Cancelled': 'Cancelled',
    };

    // Backend allows exactly one next step; Cancelled is never allowed here.
    final String? allowedKey = switch (currentStatus) {
      JobStatus.scheduled => 'OnTheWay',
      JobStatus.onTheWay => 'Arrived',
      JobStatus.arrived => 'InProgress',
      JobStatus.inProgress => 'Completed',
      _ => null,
    };

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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(sheetCtx)!.jobStatus,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF062B4D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...options.entries.map((entry) {
                    final isEnabled = entry.key == allowedKey;
                    final icon = _iconForStatusKey(entry.key);
                    final accent = const Color(0xFFE87722);
                    final disabledColor = Colors.grey.shade400;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: isEnabled
                            ? () {
                                Navigator.pop(sheetCtx);
                                if (entry.key == 'Completed') {
                                  _showPaymentAmountSheet(jobId);
                                } else {
                                  context.read<ProfessionalDashboardBloc>().add(UpdateStatus(jobId, entry.key));
                                }
                              }
                            : null,
                        child: Opacity(
                          opacity: isEnabled ? 1.0 : 0.5,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isEnabled ? Colors.white : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isEnabled ? const Color(0xFFE0E0E0) : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(icon, color: isEnabled ? accent : disabledColor),
                                const SizedBox(width: 14),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isEnabled ? const Color(0xFF062B4D) : disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForStatusKey(String key) {
    switch (key) {
      case 'OnTheWay':
        return Icons.directions_car_outlined;
      case 'Arrived':
        return Icons.place_outlined;
      case 'InProgress':
        return Icons.settings_outlined;
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _showPaymentAmountSheet(String jobId) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool _statusUpdated = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<ProfessionalDashboardBloc>(),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: BlocListener<ProfessionalDashboardBloc, ProfessionalDashboardState>(
              listener: (ctx, state) {
                if (state is PaymentAmountSubmitted) {
                  Navigator.pop(sheetCtx);
                  context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Amount submitted. Waiting for customer confirmation.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: StatefulBuilder(
                builder: (ctx, setSheetState) {
                  return Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const Text(
                          'Set Agreed Amount',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF062B4D)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter the final cash amount agreed with the customer.',
                          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Amount (JD)',
                            prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF062B4D)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE87722), width: 2),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ProfessionalDashboardBloc, ProfessionalDashboardState>(
                          builder: (ctx, state) {
                            final isLoading = state is RequestActionLoading || state is PaymentAmountSubmitting;
                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) return;
                                        final amount = double.parse(amountController.text.trim());

                                        // Step 1 — mark as Completed
                                        context.read<ProfessionalDashboardBloc>().add(UpdateStatus(jobId, 'Completed'));

                                        // Wait briefly for status to persist, then submit amount
                                        await Future.delayed(const Duration(milliseconds: 800));

                                        if (ctx.mounted) {
                                          context.read<ProfessionalDashboardBloc>().add(
                                                SubmitPaymentAmountEvent(jobId, amount),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE87722),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : const Text('Submit Amount',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
