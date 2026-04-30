import 'package:dartz/dartz.dart';
import 'package:gp/core/error/failures.dart';
import 'package:gp/features/settings/domain/entities/address_entity.dart';
import 'package:gp/features/settings/domain/repositories/address_repository.dart';

class GetAddressesUseCase {
  final AddressRepository repository;
  GetAddressesUseCase(this.repository);
  Future<Either<Failure, List<AddressEntity>>> call() =>
      repository.getAddresses();
}

class AddAddressUseCase {
  final AddressRepository repository;
  AddAddressUseCase(this.repository);
  Future<Either<Failure, Unit>> call(AddressEntity address) =>
      repository.addAddress(address);
}

class UpdateAddressUseCase {
  final AddressRepository repository;
  UpdateAddressUseCase(this.repository);
  Future<Either<Failure, Unit>> call(AddressEntity address) =>
      repository.updateAddress(address);
}

class DeleteAddressUseCase {
  final AddressRepository repository;
  DeleteAddressUseCase(this.repository);
  Future<Either<Failure, Unit>> call(String id) => repository.deleteAddress(id);
}
