import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../models/dashboard_stats_model.dart';

abstract class ProfessionalDashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<JobModel>> getIncomingRequests();
  Future<List<JobModel>> getScheduledJobs();
  Future<void> acceptJobRequest(String jobId);
  Future<void> declineJobRequest(String jobId);
  Future<void> updateJobStatus(String jobId, String status);
  Future<void> cancelJob(String jobId, {String? reason});
}

class ProfessionalDashboardRemoteDataSourceImpl implements ProfessionalDashboardRemoteDataSource {
  final Dio dio;

  ProfessionalDashboardRemoteDataSourceImpl({required this.dio});

  // GET /professionals/dashboard/stats
  // Response: { success, message, data: { requests, scheduled, completed } }
  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await dio.get('/professionals/dashboard/stats');
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardStatsModel.fromJson(data);
  }

  // GET /bookings/professional?status=Pending
  // Response: { success, message, data: [ ...BookingDto ] }
  @override
  Future<List<JobModel>> getIncomingRequests() async {
    final response = await dio.get(
      '/bookings/professional',
      queryParameters: {'status': 'Pending'},
    );
    final List<dynamic> data = response.data['data'] as List;
    return data.map((json) => JobModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // GET /bookings/professional/jobs/upcoming
  // Response: { success, message, data: [ ...ProJobDto ] }
  @override
  Future<List<JobModel>> getScheduledJobs() async {
    final response = await dio.get('/bookings/professional/jobs/upcoming');
    final List<dynamic> data = response.data['data'] as List;
    return data.map((json) => JobModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // POST /bookings/{id}/respond   body: { "accept": true }
  // Response: { success, message, data: BookingDto }
  @override
  Future<void> acceptJobRequest(String jobId) async {
    await dio.post(
      '/bookings/$jobId/respond',
      data: {'accept': true},
    );
  }

  // POST /bookings/{id}/respond   body: { "accept": false }
  // Response: { success, message, data: BookingDto }
  @override
  Future<void> declineJobRequest(String jobId) async {
    await dio.post(
      '/bookings/$jobId/respond',
      data: {'accept': false},
    );
  }

  // PUT /bookings/{id}/job-status   body: { "status": "OnTheWay"|"InProgress"|"Completed" }
  // Progression enforced by backend: Accepted → OnTheWay → InProgress → Completed
  // Response: { success, message, data: BookingDto }
  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    await dio.put(
      '/bookings/$jobId/job-status',
      data: {'status': status},
    );
  }

  // DELETE /bookings/professional/jobs/{id}   body: { "reason": "..." }
  @override
  Future<void> cancelJob(String jobId, {String? reason}) async {
    await dio.delete(
      '/bookings/professional/jobs/$jobId',
      data: {'reason': reason ?? ''},
      options: Options(contentType: 'application/json'),
    );
  }
}
