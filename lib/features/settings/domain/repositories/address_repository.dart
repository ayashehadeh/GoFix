import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, Unit>> addAddress(AddressEntity address);
  Future<Either<Failure, Unit>> updateAddress(AddressEntity address);
  Future<Either<Failure, Unit>> deleteAddress(String id);
}
