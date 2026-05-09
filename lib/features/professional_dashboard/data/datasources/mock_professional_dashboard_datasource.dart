import '../models/job_model.dart';
import '../models/dashboard_stats_model.dart';
import '../../domain/entities/job_entity.dart';
import 'professional_dashboard_remote_datasource.dart';

class MockProfessionalDashboardDataSource
    implements ProfessionalDashboardRemoteDataSource {
  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return const DashboardStatsModel(
      requestsCount: 2,
      scheduledCount: 2,
      completedCount: 10,
    );
  }

  @override
  Future<List<JobModel>> getIncomingRequests() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      JobModel(
        id: '1',
        clientName: 'Hamza Omar',
        serviceType: 'Leak Repair',
        location: 'Khalda',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        status: JobStatus.pending,
      ),
      JobModel(
        id: '2',
        clientName: 'Sara Ahmed',
        serviceType: 'Pipe Installation',
        location: 'Amman',
        scheduledTime: DateTime.now().add(const Duration(hours: 5)),
        status: JobStatus.pending,
      ),
      JobModel(
        id: '3',
        clientName: 'Omar Khaled',
        serviceType: 'Water Heater Repair',
        location: 'Swefieh',
        scheduledTime: DateTime.now().add(const Duration(hours: 8)),
        status: JobStatus.pending,
      ),
    ];
  }

  @override
  Future<List<JobModel>> getScheduledJobs() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      JobModel(
        id: '4',
        clientName: 'Ali Emad',
        serviceType: 'Leak Repair',
        location: 'Khalda',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        status: JobStatus.scheduled,
      ),
      JobModel(
        id: '5',
        clientName: 'Mohammed Khalil',
        serviceType: 'Bathroom Renovation',
        location: 'Swefieh',
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
        status: JobStatus.scheduled,
      ),
      JobModel(
        id: '6',
        clientName: 'Layla Hassan',
        serviceType: 'Kitchen Plumbing',
        location: 'Abdoun',
        scheduledTime: DateTime.now().add(const Duration(days: 2)),
        status: JobStatus.scheduled,
      ),
    ];
  }

  @override
  Future<void> acceptJobRequest(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock: Accepted job request $jobId');
    // In real app, this would move the job from pending to scheduled
  }

  @override
  Future<void> declineJobRequest(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock: Declined job request $jobId');
    // In real app, this would remove/decline the request
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Mock: Updated job $jobId status to $status');
    // In real app, this would update the job status in backend
  }
}
