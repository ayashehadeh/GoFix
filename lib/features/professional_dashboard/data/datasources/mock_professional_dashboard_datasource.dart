import '../models/job_model.dart';
import '../models/dashboard_stats_model.dart';
import '../../domain/entities/job_entity.dart';
import 'professional_dashboard_remote_datasource.dart';

class MockProfessionalDashboardDataSource
    implements ProfessionalDashboardRemoteDataSource {
  // ── In-memory mutable lists so accept/decline actually work ───────────────

  final List<JobModel> _pending = [
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

  final List<JobModel> _scheduled = [
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

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return DashboardStatsModel(
      requestsCount: _pending.length,
      scheduledCount: _scheduled.length,
      completedCount: 10,
    );
  }

  @override
  Future<List<JobModel>> getIncomingRequests() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_pending);
  }

  @override
  Future<List<JobModel>> getScheduledJobs() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.unmodifiable(_scheduled);
  }

  @override
  Future<void> acceptJobRequest(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _pending.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    final job = _pending[index];
    _pending.removeAt(index);
    // Move to scheduled list
    _scheduled.insert(
      0,
      JobModel(
        id: job.id,
        clientName: job.clientName,
        serviceType: job.serviceType,
        location: job.location,
        scheduledTime: job.scheduledTime,
        status: JobStatus.scheduled,
        clientImage: job.clientImage,
      ),
    );
  }

  @override
  Future<void> declineJobRequest(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _pending.removeWhere((j) => j.id == jobId);
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _scheduled.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    final job = _scheduled[index];
    _scheduled[index] = JobModel(
      id: job.id,
      clientName: job.clientName,
      serviceType: job.serviceType,
      location: job.location,
      scheduledTime: job.scheduledTime,
      status: JobStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => JobStatus.scheduled,
      ),
      clientImage: job.clientImage,
    );
  }
}
