import 'package:dio/dio.dart';
import '../models/availability_model.dart';

abstract class AvailabilityRemoteDataSource {
  Future<AvailabilityModel> getWorkingHours();
  Future<void> setWorkingHours(AvailabilityModel availability);
  Future<void> toggleAvailability({required bool isAvailable});
}

class AvailabilityRemoteDataSourceImpl implements AvailabilityRemoteDataSource {
  final Dio dio;

  AvailabilityRemoteDataSourceImpl({required this.dio});

  // GET /professionals/profile/working-hours
  // Response: { success, message, data: { isAvailable: bool, schedules: [...] } }
  @override
  Future<AvailabilityModel> getWorkingHours() async {
    final response = await dio.get('/professionals/profile/working-hours');
    final data = response.data['data'] as Map<String, dynamic>;
    return AvailabilityModel.fromJson(data);
  }

  // PUT /professionals/profile/working-hours
  // Body: { "schedules": [ { "dayLabel": "Monday", "openTime": "08:00", "closeTime": "17:00" }, ... ] }
  // Response: { success, message, data: null }
  @override
  Future<void> setWorkingHours(AvailabilityModel availability) async {
    await dio.put(
      '/professionals/profile/working-hours',
      data: {
        'schedules': availability.schedules
            .map((s) => {
                  'dayLabel': s.day,
                  'openTime': s.openTime,
                  'closeTime': s.closeTime,
                })
            .toList(),
      },
    );
  }

  // PUT /professionals/profile/availability
  // Body: { "isAvailable": true | false }
  // Response: { success, message, data: null }
  @override
  Future<void> toggleAvailability({required bool isAvailable}) async {
    await dio.put(
      '/professionals/profile/availability',
      data: {'isAvailable': isAvailable},
    );
  }
}
