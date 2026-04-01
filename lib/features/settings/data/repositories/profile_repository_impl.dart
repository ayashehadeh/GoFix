import 'package:dartz/dartz.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<Either<String, ProfileEntity>> getProfile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(ProfileModel(
        name: 'Hazim Amir',
        phone: '+9627xxxxxx52',
        email: 'haz***@gmail.com',
        dateOfBirth: '06-10-2004',
        gender: 'Male',
      ));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateName(String name) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: http.put('/api/profile/name')
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updatePhone(String phone) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: http.put('/api/profile/phone')
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateEmail(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: http.put('/api/profile/email')
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateDateOfBirth(String dob) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: http.put('/api/profile/dob')
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateGender(String gender) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // TODO: http.put('/api/profile/gender')
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
