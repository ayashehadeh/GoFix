import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/data/datasources/address_remote_datasource.dart';
import 'package:gp/features/settings/data/models/address_model.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final result = await remoteDataSource.getAddresses();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addAddress(AddressEntity address) async {
    try {
      final model = AddressModel.fromEntity(address);
      await remoteDataSource.addAddress(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAddress(AddressEntity address) async {
    try {
      final model = AddressModel.fromEntity(address);
      await remoteDataSource.updateAddress(model);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress(String id) async {
    try {
      await remoteDataSource.deleteAddress(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
