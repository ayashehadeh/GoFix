import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/widgets/skeletons/booking_job_list_skeleton.dart';
import '../bloc/professional_jobs_bloc.dart';
import '../bloc/professional_jobs_event.dart';
import '../bloc/professional_jobs_state.dart';
import '../widgets/pro_job_list_card.dart';
import 'job_info_page.dart';
import '../../domain/entities/pro_job.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_bloc.dart';
import 'package:gp/injection_container.dart' as di;

class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage> {
  bool _isUpcoming = true;

  @override
  void initState() {
    super.initState();
    context.read<ProfessionalJobsBloc>().add(LoadUpcomingJobs());
  }

  void _switchTab(bool isUpcoming) {
    if (_isUpcoming == isUpcoming) return;
    setState(() => _isUpcoming = isUpcoming);
    if (isUpcoming) {
      context.read<ProfessionalJobsBloc>().add(LoadUpcomingJobs());
    } else {
      context.read<ProfessionalJobsBloc>().add(LoadPastJobs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfessionalJobsBloc, ProfessionalJobsState>(
      listener: (context, state) {
        if (state is JobStatusUpdateSuccess) {
          final msg = state.movedToPast
              ? 'Job marked as ${state.updatedJob.status.label}'
              : 'Status updated to ${state.updatedJob.status.label}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: const Color(0xFFFF8C1A),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reload the upcoming list to reflect any changes
          context.read<ProfessionalJobsBloc>().add(LoadUpcomingJobs());
          setState(() => _isUpcoming = true);
        }
        if (state is ProfessionalJobsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _Header(
                isUpcoming: _isUpcoming,
                onSwitchTab: _switchTab,
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: BlocBuilder<ProfessionalJobsBloc, ProfessionalJobsState>(
                  builder: (context, state) {
                    if (state is ProfessionalJobsLoading || state is JobStatusUpdateLoading) {
                      return const BookingJobListSkeleton();
                    }

                    if (state is ProfessionalJobsLoaded) {
                      if (state.jobs.isEmpty) {
                        return _EmptyState(isUpcoming: _isUpcoming);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: state.jobs.length,
                        itemBuilder: (context, index) {
                          final job = state.jobs[index];
                          return ProJobListCard(
                            job: job,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<ProfessionalJobsBloc>()),
                                    BlocProvider(create: (_) => di.sl<ProfessionalDashboardBloc>()),
                                  ],
                                  child: JobInfoPage(job: job),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header with tab toggle ───────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isUpcoming;
  final void Function(bool) onSwitchTab;
  final VoidCallback onBack;

  const _Header({
    required this.isUpcoming,
    required this.onSwitchTab,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF062B4D)),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF062B4D),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TabBtn(
                label: 'Upcoming',
                isActive: isUpcoming,
                onTap: () => onSwitchTab(true),
              ),
              const SizedBox(width: 10),
              _TabBtn(
                label: 'Past',
                isActive: !isUpcoming,
                onTap: () => onSwitchTab(false),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8C1A) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive ? const Color(0xFFFF8C1A) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isUpcoming;
  const _EmptyState({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.work_outline : Icons.history,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No upcoming jobs' : 'No past jobs yet',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
