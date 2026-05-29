import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/core/widgets/skeletons/booking_job_list_skeleton.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_bloc.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_event.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_state.dart';
import 'package:gp/features/professional_jobs/presentation/widgets/pro_job_list_card.dart';
import 'job_request_info_page.dart';

class IncomingRequestsPage extends StatelessWidget {
  const IncomingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<ProfessionalDashboardBloc, ProfessionalDashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const BookingJobListSkeleton();
                  }
                  if (state is DashboardLoaded) {
                    final requests = state.incomingRequests;
                    if (requests.isEmpty) {
                      return _buildEmpty();
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProfessionalDashboardBloc>().add(RefreshDashboard());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return ProJobListCard(
                            job: request,
                            onTap: () => Navigator.push(
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
                            }),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF062B4D)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Incoming Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF062B4D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No incoming requests',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
