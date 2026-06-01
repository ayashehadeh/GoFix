import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';
import '../models/earning_model.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  static const String cachedEarningsKey = 'CACHED_EARNINGS';

  EarningsRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, Map<String, Earning>>> getEarnings() async {
    final result = await _fetchFromRemote();
    if (result.isRight()) return result;

    // Network failed — fall back to cache
    final cachedData = await _getCachedEarnings();
    if (cachedData != null) return Right(cachedData);
    return result;
  }

  @override
  Future<Either<Failure, Map<String, Earning>>> refreshEarnings() async {
    return await _fetchFromRemote();
  }

  Future<Either<Failure, Map<String, Earning>>> _fetchFromRemote() async {
    try {
      final remoteData = await remoteDataSource.getEarnings();

      // Cache the data
      await _cacheEarnings(remoteData);

      // Convert models to entities
      final entities =
          remoteData.map((key, value) => MapEntry(key, value.toEntity()));
      return Right(entities);
    } on Exception catch (e) {
      if (e.toString().contains('Unauthorized')) {
        return const Left(ServerFailure('Please login again'));
      }
      return const Left(NetworkFailure('Network Failure'));
    }
  }

  Future<Map<String, Earning>?> _getCachedEarnings() async {
    final jsonString = sharedPreferences.getString(cachedEarningsKey);
    if (jsonString != null) {
      final jsonData = json.decode(jsonString);
      return {
        'daily': EarningModel.fromJson(jsonData['daily']).toEntity(),
        'weekly': EarningModel.fromJson(jsonData['weekly']).toEntity(),
        'monthly': EarningModel.fromJson(jsonData['monthly']).toEntity(),
      };
    }
    return null;
  }

  Future<void> _cacheEarnings(Map<String, EarningModel> earnings) async {
    final jsonData =
        earnings.map((key, value) => MapEntry(key, value.toJson()));
    await sharedPreferences.setString(cachedEarningsKey, json.encode(jsonData));
  }
}
