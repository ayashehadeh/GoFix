import '../models/job_model.dart';
import '../models/dashboard_stats_model.dart';
import 'package:gp/features/professional_jobs/domain/entities/pro_job.dart';
import 'professional_dashboard_remote_datasource.dart';

class MockProfessionalDashboardDataSource
    implements ProfessionalDashboardRemoteDataSource {
  final List<JobModel> _pending = [
    JobModel(
      id: '1',
      clientName: 'Hamza Omar',
      clientImageUrl: '',
      serviceType: 'Leak Repair',
      location: 'Khalda',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      price: '',
      description: '',
      status: ProJobStatus.pending,
    ),
    JobModel(
      id: '2',
      clientName: 'Sara Ahmed',
      clientImageUrl: '',
      serviceType: 'Pipe Installation',
      location: 'Amman',
      scheduledTime: DateTime.now().add(const Duration(hours: 5)),
      price: '',
      description: '',
      status: ProJobStatus.pending,
    ),
    JobModel(
      id: '3',
      clientName: 'Omar Khaled',
      clientImageUrl: '',
      serviceType: 'Water Heater Repair',
      location: 'Swefieh',
      scheduledTime: DateTime.now().add(const Duration(hours: 8)),
      price: '',
      description: '',
      status: ProJobStatus.pending,
    ),
  ];

  final List<JobModel> _scheduled = [
    JobModel(
      id: '4',
      clientName: 'Ali Emad',
      clientImageUrl: '',
      serviceType: 'Leak Repair',
      location: 'Khalda',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      price: '',
      description: '',
      status: ProJobStatus.confirmed,
    ),
    JobModel(
      id: '5',
      clientName: 'Mohammed Khalil',
      clientImageUrl: '',
      serviceType: 'Bathroom Renovation',
      location: 'Swefieh',
      scheduledTime: DateTime.now().add(const Duration(days: 1)),
      price: '',
      description: '',
      status: ProJobStatus.confirmed,
    ),
    JobModel(
      id: '6',
      clientName: 'Layla Hassan',
      clientImageUrl: '',
      serviceType: 'Kitchen Plumbing',
      location: 'Abdoun',
      scheduledTime: DateTime.now().add(const Duration(days: 2)),
      price: '',
      description: '',
      status: ProJobStatus.confirmed,
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
    _scheduled.insert(
      0,
      JobModel(
        id: job.id,
        clientName: job.clientName,
        clientImageUrl: job.clientImageUrl,
        serviceType: job.serviceType,
        location: job.location,
        scheduledTime: job.scheduledTime,
        price: job.price,
        description: job.description,
        status: ProJobStatus.confirmed,
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
      clientImageUrl: job.clientImageUrl,
      serviceType: job.serviceType,
      location: job.location,
      scheduledTime: job.scheduledTime,
      price: job.price,
      description: job.description,
      status: ProJobStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == status.toLowerCase(),
        orElse: () => ProJobStatus.confirmed,
      ),
    );
  }
}
