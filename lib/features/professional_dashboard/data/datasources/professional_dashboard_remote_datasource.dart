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
}

class ProfessionalDashboardRemoteDataSourceImpl
    implements ProfessionalDashboardRemoteDataSource {
  final Dio dio;

  ProfessionalDashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await dio.get('/api/professional/dashboard/stats');
      if (response.statusCode == 200) {
        return DashboardStatsModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }

  @override
  Future<List<JobModel>> getIncomingRequests() async {
    try {
      final response = await dio.get('/api/professional/requests/incoming');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['requests'] ?? response.data;
        return data.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load incoming requests');
      }
    } catch (e) {
      throw Exception('Error fetching incoming requests: $e');
    }
  }

  @override
  Future<List<JobModel>> getScheduledJobs() async {
    try {
      final response = await dio.get('/api/professional/jobs/scheduled');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['jobs'] ?? response.data;
        return data.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load scheduled jobs');
      }
    } catch (e) {
      throw Exception('Error fetching scheduled jobs: $e');
    }
  }

  @override
  Future<void> acceptJobRequest(String jobId) async {
    try {
      final response = await dio.post(
        '/api/professional/requests/$jobId/accept',
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to accept job request');
      }
    } catch (e) {
      throw Exception('Error accepting job request: $e');
    }
  }

  @override
  Future<void> declineJobRequest(String jobId) async {
    try {
      final response = await dio.post(
        '/api/professional/requests/$jobId/decline',
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to decline job request');
      }
    } catch (e) {
      throw Exception('Error declining job request: $e');
    }
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      final response = await dio.patch(
        '/api/professional/jobs/$jobId/status',
        data: {'status': status},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update job status');
      }
    } catch (e) {
      throw Exception('Error updating job status: $e');
    }
  }
}
