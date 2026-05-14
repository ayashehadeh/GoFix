import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/professional_dashboard_bloc.dart';
import '../bloc/professional_dashboard_event.dart';
import '../bloc/professional_dashboard_state.dart';
import '../../../professional_availability/presentation/bloc/availability_bloc.dart';
import '../../../professional_availability/presentation/pages/my_availability_screen.dart';
import '../../../../core/widgets/gofix_bottom_nav_bar.dart';
import '../../../../injection_container.dart' as di;
import 'package:gp/core/utils/user_info_helper.dart';

class ProfessionalDashboardScreen extends StatefulWidget {
  const ProfessionalDashboardScreen({Key? key})
      : super(key: key); // remove professionalName param

  @override
  State<ProfessionalDashboardScreen> createState() =>
      _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState
    extends State<ProfessionalDashboardScreen> {
  String _userName = '';
  @override
  void initState() {
    super.initState();
    context.read<ProfessionalDashboardBloc>().add(LoadDashboard());
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    // ADD THIS
    final name = await UserInfoHelper.getFullName();
    if (mounted) setState(() => _userName = name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: BlocConsumer<ProfessionalDashboardBloc, ProfessionalDashboardState>(
          listenWhen: (_, current) => current is RequestActionSuccess || current is RequestActionError,
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
          buildWhen: (_, current) =>
              current is DashboardLoading || current is DashboardLoaded || current is DashboardError,
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}',
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ProfessionalDashboardBloc>()
                          .add(RefreshDashboard()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<ProfessionalDashboardBloc>()
                      .add(RefreshDashboard());
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
          if (index == 0) Navigator.of(context).pushReplacementNamed('/home');
          if (index == 1)
            Navigator.of(context).pushReplacementNamed('/bookings');
          if (index == 2)
            Navigator.of(context).pushReplacementNamed('/profile');
          if (index == 3) return; // already here
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
                      'Good ${_getTimeOfDay()}, $_userName',
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
                  _buildStatCard('${state.stats.requestsCount}', 'Requests'),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2)),
                  _buildStatCard('${state.stats.scheduledCount}', 'Scheduled'),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.2)),
                  _buildStatCard('${state.stats.completedCount}', 'Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStatCard(String count, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
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
              const Text('Scheduled Jobs',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A5C))),
              if (state.scheduledJobs.isNotEmpty)
                TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: state.scheduledJobs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('No scheduled jobs yet',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.scheduledJobs.length,
                  itemBuilder: (context, index) =>
                      _buildScheduledJobCard(state.scheduledJobs[index]),
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1A3A5C),
                child: Text(
                    job.clientName.isNotEmpty
                        ? job.clientName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.clientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(job.serviceType,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(job.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(DateFormat('MMM d, h:mm a').format(job.scheduledTime),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showStatusUpdateDialog(job.id, job.status),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE87722),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Update Status',
                  style: TextStyle(color: Colors.white)),
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
              const Text('Incoming Requests',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A5C))),
              if (state.incomingRequests.isNotEmpty)
                TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: state.incomingRequests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('No incoming requests',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.incomingRequests.length,
                  itemBuilder: (context, index) =>
                      _buildRequestCard(state.incomingRequests[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(JobEntity request) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1A3A5C),
                child: Text(
                    request.clientName.isNotEmpty
                        ? request.clientName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.clientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(request.serviceType,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(request.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    overflow: TextOverflow.ellipsis),
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
                  onPressed: () => context
                      .read<ProfessionalDashboardBloc>()
                      .add(DeclineRequest(request.id)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context
                      .read<ProfessionalDashboardBloc>()
                      .add(AcceptRequest(request.id)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE87722),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Accept',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem('My Availability', Icons.schedule, () {
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
          _buildMenuItem('My Jobs', Icons.work_outline, () {
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
          _buildMenuItem('My Profile', Icons.person_outline, () {}),
          _buildMenuItem('My Earnings', Icons.attach_money, () {}),
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
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Status dialog — uses correct backend status values
  void _showStatusUpdateDialog(String jobId, JobStatus currentStatus) {
    final next = {
      JobStatus.scheduled: MapEntry('OnTheWay', 'On The Way'),
      JobStatus.onTheWay: MapEntry('InProgress', 'In Progress'),
      JobStatus.inProgress: MapEntry('Completed', 'Completed'),
    }[currentStatus];

    if (next == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Job Status'),
        content: ListTile(
          title: Text(next.value),
          onTap: () {
            this.context.read<ProfessionalDashboardBloc>().add(
                  UpdateStatus(jobId, next.key),
                );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
