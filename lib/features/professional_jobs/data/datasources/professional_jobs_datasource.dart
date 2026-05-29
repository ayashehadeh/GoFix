import 'package:dio/dio.dart';
import '../models/pro_job_model.dart';
import '../../domain/entities/pro_job.dart';

abstract class ProfessionalJobsRemoteDataSource {
  Future<List<ProJobModel>> getUpcomingJobs();
  Future<List<ProJobModel>> getPastJobs();
  Future<ProJobModel> updateJobStatus({
    required String jobId,
    required ProJobStatus newStatus,
  });
  Future<void> cancelJob(String jobId, {String? reason});
}

class ProfessionalJobsRemoteDataSourceImpl implements ProfessionalJobsRemoteDataSource {
  final Dio dio;

  const ProfessionalJobsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProJobModel>> getUpcomingJobs() async {
    final response = await dio.get('/bookings/professional/jobs/upcoming');
    final data = response.data['data'] as List;
    return data.map((e) => ProJobModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProJobModel>> getPastJobs() async {
    final response = await dio.get('/bookings/professional/jobs/past');
    final data = response.data['data'] as List;
    return data.map((e) => ProJobModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProJobModel> updateJobStatus({
    required String jobId,
    required ProJobStatus newStatus,
  }) async {
    await dio.put(
      '/bookings/$jobId/job-status',
      data: {'status': _statusToString(newStatus)},
    );
    // Re-fetch the updated job to get ProJobDto format
    final response = await dio.get('/bookings/professional/jobs/$jobId');
    return ProJobModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> cancelJob(String jobId, {String? reason}) async {
    await dio.delete(
      '/bookings/professional/jobs/$jobId',
      data: {'reason': reason ?? ''},
      options: Options(contentType: 'application/json'),
    );
  }

  String _statusToString(ProJobStatus status) {
    switch (status) {
      case ProJobStatus.onTheWay:
        return 'OnTheWay';
      case ProJobStatus.arrived:
        return 'Arrived';
      case ProJobStatus.inProgress:
        return 'InProgress';
      case ProJobStatus.completed:
        return 'Completed';
      default:
        return status.name;
    }
  }
}

/// Mock implementation — all data matches the design exactly.
/// Completed / Cancelled jobs are automatically moved from upcoming → past.
class MockProfessionalJobsDataSource implements ProfessionalJobsRemoteDataSource {
  // ── In-memory mutable lists ─────────────────────────────────────────────────

  final List<ProJobModel> _upcoming = [
    ProJobModel(
      id: 'j1',
      clientName: 'Farouq Ahmad',
      clientImageUrl: '',
      serviceType: 'Pipe Installation',
      location: 'AlJubaiha',
      scheduledTime: DateTime(2025, 2, 5, 15, 0),
      price: '30 JD',
      description: 'Pipe under the kitchen sink has been leaking for 2 days. '
          'Water is dripping onto the cabinet floor. Need it fixed as soon as possible.',
      status: ProJobStatus.pending,
    ),
    ProJobModel(
      id: 'j2',
      clientName: 'Alaa Qasem',
      clientImageUrl: '',
      serviceType: 'Leak Repair',
      location: 'Sweifieh',
      scheduledTime: DateTime(2025, 2, 2, 10, 0),
      price: '20 JD',
      description: 'Water leak from the bathroom ceiling.',
      status: ProJobStatus.confirmed,
    ),
    ProJobModel(
      id: 'j3',
      clientName: 'Omar Amer',
      clientImageUrl: '',
      serviceType: 'Water Heater Service',
      location: 'Khalda',
      scheduledTime: DateTime(2025, 1, 2, 11, 0),
      price: '50 JD',
      description: 'Water heater is not working properly.',
      status: ProJobStatus.inProgress,
    ),
  ];

  final List<ProJobModel> _past = [
    ProJobModel(
      id: 'j4',
      clientName: 'Yousef Amjad',
      clientImageUrl: '',
      serviceType: 'Pipe Installation',
      location: 'AlJubaiha',
      scheduledTime: DateTime(2025, 2, 5, 15, 0),
      price: '30 JD',
      description: 'Full pipe replacement in kitchen.',
      status: ProJobStatus.completed,
    ),
    ProJobModel(
      id: 'j5',
      clientName: 'Sara Ghassan',
      clientImageUrl: '',
      serviceType: 'Leak Repair',
      location: 'Sweifieh',
      scheduledTime: DateTime(2025, 2, 2, 9, 0),
      price: '20 JD',
      // AFTER — j5
      description: 'Leak under bathroom sink.',
      status: ProJobStatus.cancelled,
    ),
    ProJobModel(
      id: 'j6',
      clientName: 'Basel Omar',
      clientImageUrl: '',
      serviceType: 'Water Heater Service',
      location: 'Khalda',
      scheduledTime: DateTime(2025, 1, 2, 14, 0),
      price: '50 JD',
      // AFTER — j6
      description: 'Water heater annual maintenance.',
      status: ProJobStatus.completed,
    ),
  ];

  // ── Interface ───────────────────────────────────────────────────────────────

  @override
  Future<List<ProJobModel>> getUpcomingJobs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_upcoming);
  }

  @override
  Future<List<ProJobModel>> getPastJobs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_past);
  }

  @override
  Future<ProJobModel> updateJobStatus({
    required String jobId,
    required ProJobStatus newStatus,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _upcoming.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job $jobId not found');

    final existing = _upcoming[index];
    final updated = ProJobModel(
      id: existing.id,
      clientName: existing.clientName,
      clientImageUrl: existing.clientImageUrl,
      serviceType: existing.serviceType,
      location: existing.location,
      scheduledTime: existing.scheduledTime,
      price: existing.price,
      description: existing.description,
      imageUrls: existing.imageUrls,
      status: newStatus,
    );

    if (!newStatus.isActive) {
      _upcoming.removeAt(index);
      _past.insert(0, updated);
    } else {
      _upcoming[index] = updated;
    }

    return updated;
  }

  @override
  Future<void> cancelJob(String jobId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _upcoming.indexWhere((j) => j.id == jobId);
    if (index == -1) throw Exception('Job $jobId not found');
    final existing = _upcoming.removeAt(index);
    _past.insert(0, ProJobModel(
      id: existing.id,
      clientName: existing.clientName,
      clientImageUrl: existing.clientImageUrl,
      serviceType: existing.serviceType,
      location: existing.location,
      scheduledTime: existing.scheduledTime,
      price: existing.price,
      description: existing.description,
      imageUrls: existing.imageUrls,
      status: ProJobStatus.cancelled,
    ));
  }
}
