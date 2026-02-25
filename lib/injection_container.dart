import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/features/home/data/data_sources/data_remote_datasource.dart';
import 'package:gp/features/home/domain/use_cases/get_categories_usecase.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── BLoC ──────────────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(
    getCategoriesUseCase: sl(),
  ));

  // ── Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // ── Repository ────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Data Sources ──────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );

  // ── External ──────────────────────────────────────────────────────
  sl.registerLazySingleton(() => Dio(
    BaseOptions(
      baseUrl: 'https://your-api.com/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  ));
}