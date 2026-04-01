import 'package:dartz/dartz.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<String, ProfileEntity>> getProfile();
  Future<Either<String, void>> updateName(String name);
  Future<Either<String, void>> updatePhone(String phone);
  Future<Either<String, void>> updateEmail(String email);
  Future<Either<String, void>> updateDateOfBirth(String dob);
  Future<Either<String, void>> updateGender(String gender);
}
