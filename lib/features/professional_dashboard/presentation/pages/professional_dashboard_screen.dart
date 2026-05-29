import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/features/professional_dashboard/presentation/pages/job_request_info_page.dart';
import 'package:gp/features/professional_jobs/presentation/bloc/professional_jobs_bloc.dart';
import 'package:gp/features/professional_jobs/presentation/pages/job_info_page.dart';
import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/features/professional_jobs/presentation/pages/my_jobs_page.dart';
import 'incoming_requests_page.dart';
import 'package:intl/intl.dart';
import '../bloc/professional_dashboard_bloc.dart';
import '../bloc/professional_dashboard_event.dart';
import '../bloc/professional_dashboard_state.dart';
import '../../../professional_availability/presentation/bloc/availability_bloc.dart';
import '../../../professional_availability/presentation/pages/my_availability_screen.dart';
import '../../../earnings/presentation/bloc/earnings_bloc.dart';
import '../../../earnings/presentation/pages/earnings_page.dart';
import '../../../../core/widgets/gofix_bottom_nav_bar.dart';
import '../../../../core/widgets/skeletons/dashboard_skeleton.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/widgets/payment_amount_sheet.dart';
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
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: BlocConsumer<ProfessionalDashboardBloc, ProfessionalDashboardState>(
          buildWhen: (prev, curr) =>
              curr is DashboardInitial || curr is DashboardLoading || curr is DashboardLoaded || curr is DashboardError,
          listener: (context, state) {
            if (state is RequestActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is RequestActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const DashboardSkeleton();
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
                      const SizedBox(height: 28),
                      _buildScheduledJobsSection(state),
                      const SizedBox(height: 28),
                      _buildIncomingRequestsSection(state),
                      const SizedBox(height: 28),
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

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeaderAndStats(BuildContext context, DashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF091929), Color(0xFF1A3A5C)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A3A5C).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTimeOfDay(AppLocalizations.of(context)!),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userName.isNotEmpty
                              ? _userName
                                  .split(' ')
                                  .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : w)
                                  .join(' ')
                              : '...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    Icons.inbox_outlined,
                    '${state.stats.requestsCount}',
                    AppLocalizations.of(context)!.totalRequests,
                    const Color(0xFFE87722),
                  ),
                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.2)),
                  _buildStatCard(
                    Icons.calendar_today_outlined,
                    '${state.stats.scheduledCount}',
                    AppLocalizations.of(context)!.scheduled,
                    const Color(0xFFE87722),
                  ),
                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.2)),
                  _buildStatCard(
                    Icons.check_circle_outline,
                    '${state.stats.completedCount}',
                    AppLocalizations.of(context)!.completedJobs,
                    const Color(0xFFE87722),
                  ),
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

  Widget _buildStatCard(IconData icon, String count, String label, Color iconColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Shared section header ────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll, bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFE87722),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C))),
            ],
          ),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFE87722)),
              child: Text(AppLocalizations.of(context)!.seeAll),
            ),
        ],
      ),
    );
  }

  // ── Scheduled jobs ───────────────────────────────────────────────────────────

  Widget _buildScheduledJobsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          AppLocalizations.of(context)!.scheduledJobsTitle,
          showSeeAll: state.scheduledJobs.isNotEmpty,
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => di.sl<ProfessionalJobsBloc>(),
                child: const MyJobsPage(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.245,
          child: state.scheduledJobs.isEmpty
              ? _buildEmptyState(Icons.event_note_outlined, AppLocalizations.of(context)!.noScheduledJobsYet)
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

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 52, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildScheduledJobCard(ProJob job) {
    final chip = _statusChipData(job.status);
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () {
          final bloc = context.read<ProfessionalDashboardBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => di.sl<ProfessionalJobsBloc>()),
                  BlocProvider.value(value: bloc),
                ],
                child: JobInfoPage(job: job),
              ),
            ),
          ).then((_) {
            if (context.mounted) bloc.add(RefreshDashboard());
          });
        },
        child: Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: const Border(left: BorderSide(color: Color(0xFF1A3A5C), width: 3)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))
            ],
          ),
        ).then((_) {
          if (context.mounted) {
            context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
          }
        });
      },
      child: Container(
      width: screenWidth * 0.72,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Color(0xFF1A3A5C), width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A3A5C).withValues(alpha: 0.1),
                      child: Text(
                        job.clientName.isNotEmpty ? job.clientName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFF1A3A5C), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                    _buildStatusChip(chip),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 15, color: Colors.grey[500]),
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
                    Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM d, h:mm a').format(job.scheduledTime),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d, h:mm a').format(job.scheduledTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(job.id, job.status),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE87722),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
              ],
            ),
          ),
        ));
  }

  ({String label, Color color, Color bg}) _statusChipData(ProJobStatus status) {
    return switch (status) {
      ProJobStatus.pending => (label: 'Pending', color: const Color(0xFF795548), bg: const Color(0xFFF5EFEB)),
      ProJobStatus.confirmed => (label: 'Scheduled', color: const Color(0xFF1A3A5C), bg: const Color(0xFFE8F0F8)),
      ProJobStatus.onTheWay => (label: 'On The Way', color: const Color(0xFFE87722), bg: const Color(0xFFFFF3E8)),
      ProJobStatus.arrived => (label: 'Arrived', color: const Color(0xFF1A3A5C), bg: const Color(0xFFE8F0F8)),
      ProJobStatus.inProgress => (label: 'In Progress', color: const Color(0xFFE87722), bg: const Color(0xFFFFF3E8)),
      ProJobStatus.completed => (label: 'Completed', color: const Color(0xFF1A3A5C), bg: const Color(0xFFE8F0F8)),
      ProJobStatus.cancelled => (label: 'Cancelled', color: const Color(0xFF757575), bg: const Color(0xFFF0F0F0)),
    };
  }

  Widget _buildStatusChip(({String label, Color color, Color bg}) data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        data.label,
        style: TextStyle(color: data.color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ── Incoming requests ────────────────────────────────────────────────────────

  Widget _buildIncomingRequestsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          AppLocalizations.of(context)!.incomingRequestsTitle,
          showSeeAll: state.incomingRequests.isNotEmpty,
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProfessionalDashboardBloc>(),
                child: const IncomingRequestsPage(),
              ),
            ),
          ).then((_) {
            if (mounted) {
              context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
            }
          }),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.26,
          child: state.incomingRequests.isEmpty
              ? _buildEmptyState(Icons.inbox_outlined, AppLocalizations.of(context)!.noIncomingRequests)
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
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        final bloc = context.read<ProfessionalDashboardBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: JobRequestInfoPage(job: request),
            ),
          ),
        ).then((_) {
          if (context.mounted) bloc.add(RefreshDashboard());
        });
      },
      child: Container(
        width: screenWidth * 0.72,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border(left: BorderSide(color: Color(0xFFE87722), width: 3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE87722).withValues(alpha: 0.12),
                    child: Text(
                      request.clientName.isNotEmpty ? request.clientName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Color(0xFFE87722), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.clientName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(request.serviceType,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(request.location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM d, h:mm a').format(request.scheduledTime),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showDeclineSheet(request.id),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(AppLocalizations.of(context)!.declineLabel,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<ProfessionalDashboardBloc>().add(AcceptRequest(request.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87722),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(AppLocalizations.of(context)!.acceptLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick access grid ────────────────────────────────────────────────────────

  Widget _buildMenuItems(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quick Access'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.3,
            children: [
              _buildMenuGridCard(
                t.myAvailability,
                Icons.schedule_outlined,
                const Color(0xFF1A3A5C),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<AvailabilityBloc>(),
                      child: const MyAvailabilityScreen(),
                    ),
                  ),
                ),
              ),
              _buildMenuGridCard(
                t.myJobs,
                Icons.work_outline,
                const Color(0xFFE87722),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<ProfessionalJobsBloc>(),
                      child: const MyJobsPage(),
                    ),
                  ),
                ),
              ),
              _buildMenuGridCard(
                t.myProfile,
                Icons.person_outline,
                const Color(0xFF1A3A5C),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<ProfessionalsBloc>(),
                      child: const ProfessionalMyProfilePage(),
                    ),
                  ),
                ),
              ),
              _buildMenuGridCard(
                t.myEarnings,
                Icons.account_balance_wallet_outlined,
                const Color(0xFFE87722),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<EarningsBloc>(),
                      child: const EarningsPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGridCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text('View', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(width: 2),
                Icon(Icons.arrow_forward, size: 12, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Decline confirmation sheet ───────────────────────────────────────────────

  void _showDeclineSheet(String jobId) {
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
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
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
                    Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: Color(0xFFE87722), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(sheetCtx)!.reasonOptional,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF062B4D),
                          ),
                        ),
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        bloc.add(DeclineRequest(jobId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87722),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(sheetCtx)!.done,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  // ── Status update dialogs ────────────────────────────────────────────────────

  void _showStatusUpdateDialog(String jobId, ProJobStatus currentStatus) {
    final Set<String> allowedKeys = switch (currentStatus) {
      ProJobStatus.confirmed => {'OnTheWay', 'Cancelled'},
      ProJobStatus.onTheWay => {'Arrived', 'Cancelled'},
      ProJobStatus.arrived => {'InProgress', 'Cancelled'},
      ProJobStatus.inProgress => {'Completed', 'Cancelled'},
      _ => {},
    };

    final options = [
      (
        key: 'OnTheWay',
        title: 'On The Way',
        subtitle: "Let the customer know you're heading over.",
        icon: Icons.directions_car_outlined
      ),
      (key: 'Arrived', title: 'Arrived', subtitle: "You're at the client's location.", icon: Icons.place_outlined),
      (key: 'InProgress', title: 'In Progress', subtitle: "You've started the job.", icon: Icons.settings_outlined),
      (
        key: 'Completed',
        title: 'Completed',
        subtitle: "The job is done successfully.",
        icon: Icons.check_circle_outline
      ),
      (
        key: 'Cancelled',
        title: 'Cancelled',
        subtitle: "Only use if the job can't be completed.",
        icon: Icons.cancel_outlined
      ),
    ];

    String? selected;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withValues(alpha: 0.25)),
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
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                    Text(
                      AppLocalizations.of(sheetCtx)!.jobStatus,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF062B4D)),
                    ),
                    const SizedBox(height: 20),
                    ...options.map((opt) {
                      final isEnabled = allowedKeys.contains(opt.key);
                      final isSelected = selected == opt.key;
                      final isCancelled = opt.key == 'Cancelled';
                      final iconColor = isCancelled ? Colors.grey : const Color(0xFFE87722);
                      return Opacity(
                        opacity: isEnabled ? 1.0 : 0.4,
                        child: GestureDetector(
                          onTap: isEnabled ? () => setSheetState(() => selected = opt.key) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFE87722) : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(opt.icon, color: iconColor, size: 26),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(opt.title,
                                          style: const TextStyle(
                                              fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF062B4D))),
                                      const SizedBox(height: 3),
                                      Text(opt.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFE87722), size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selected == null
                          ? null
                          : () {
                              Navigator.pop(sheetCtx);
                              if (selected == 'Completed') {
                                _showPaymentAmountSheet(jobId);
                              } else {
                                context.read<ProfessionalDashboardBloc>().add(UpdateStatus(jobId, selected!));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE87722),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(sheetCtx)!.confirmUpdate,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentAmountSheet(String jobId) {
    showPaymentAmountSheet(
      context,
      jobId: jobId,
      onSuccess: () {
        if (mounted) context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
      },
    );
  }
}
