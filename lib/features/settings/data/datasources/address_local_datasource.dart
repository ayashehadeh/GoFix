import 'package:gp/features/settings/data/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<void> addAddress(AddressModel address);
  Future<void> updateAddress(AddressModel address);
  Future<void> deleteAddress(String id);
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  static const _key = 'user_addresses';

  @override
  Future<List<AddressModel>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    return AddressModel.listFromJson(jsonStr);
  }

  @override
  Future<void> addAddress(AddressModel address) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAddresses();
    final newAddress = AddressModel.fromJson(
      address.toJson()..['id'] = const Uuid().v4(),
    );
    list.add(newAddress);
    await prefs.setString(_key, AddressModel.listToJson(list));
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAddresses();
    final index = list.indexWhere((a) => a.id == address.id);
    if (index != -1) list[index] = address;
    await prefs.setString(_key, AddressModel.listToJson(list));
  }

  @override
  Future<void> deleteAddress(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAddresses();
    list.removeWhere((a) => a.id == id);
    await prefs.setString(_key, AddressModel.listToJson(list));
  }
}
