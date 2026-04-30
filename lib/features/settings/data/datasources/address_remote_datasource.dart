import 'package:dio/dio.dart';
import 'package:gp/features/settings/data/models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<void> addAddress(AddressModel address);
  Future<void> updateAddress(AddressModel address);
  Future<void> deleteAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio dio;

  AddressRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await dio.get('/settings/addresses');
    final list = response.data['data'] as List;
    return list.map((e) => AddressModel.fromJson(e)).toList();
  }

  @override
  Future<void> addAddress(AddressModel address) async {
    await dio.post('/settings/addresses', data: address.toJson());
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    await dio.put('/settings/addresses/${address.id}', data: address.toJson());
  }

  @override
  Future<void> deleteAddress(String id) async {
    await dio.delete('/settings/addresses/$id');
  }
}
