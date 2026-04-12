import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:gp/features/settings/domain/entities/profile_entity.dart';
import 'package:gp/features/settings/domain/repositories/profile_repository.dart';
import 'package:gp/features/settings/data/models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio dio;

  ProfileRepositoryImpl({required this.dio});

  @override
  Future<Either<String, ProfileEntity>> getProfile() async {
    try {
      final response = await dio.get('/settings/profile');
      final data = response.data['data'];
      return Right(ProfileModel.fromJson(data));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to load profile.';
      return Left(msg);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateName(String name) async {
    try {
      await dio.put('/settings/profile/name', data: {'name': name});
      return const Right(null);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to update name.';
      return Left(msg);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updatePhone(String phone) async {
    try {
      await dio.put('/settings/profile/phone', data: {'phone': phone});
      return const Right(null);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to update phone.';
      return Left(msg);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateEmail(String email) async {
    try {
      await dio.put('/settings/profile/email', data: {'email': email});
      return const Right(null);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to update email.';
      return Left(msg);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateDateOfBirth(String dob) async {
    try {
      await dio.put('/settings/profile/dob', data: {'dateOfBirth': dob});
      return const Right(null);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] ?? 'Failed to update date of birth.';
      return Left(msg);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateGender(String gender) async {
    try {
      await dio.put('/settings/profile/gender', data: {'gender': gender});
      return const Right(null);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to update gender.';
      return Left(msg);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
