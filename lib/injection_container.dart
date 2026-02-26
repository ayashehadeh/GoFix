import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/features/home/data/data_sources/data_remote_datasource.dart';
import 'package:gp/features/home/domain/use_cases/get_categories_usecase.dart';
import 'package:gp/features/professionals/data/datasources/professionals_remote_datasource.dart';
import 'package:gp/features/professionals/data/repositories/professionals_repository_impl.dart';
import 'package:gp/features/professionals/domain/repositories/professionals_repository.dart';
import 'package:gp/features/professionals/domain/repositories/reviews_repository.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/add_review.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/delete_review.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/edit_review.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/filter_professionals.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_favorites.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_professional_by_id.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_professionals_by_category.dart';
import 'package:gp/features/professionals/domain/usecases/review_usecases/get_reviews_by_professional.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/search_professionals.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/toggle_favorite.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── BLoC ──────────────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(
        getCategoriesUseCase: sl(),
      ));

  sl.registerFactory(() => ProfessionalsBloc(
        getProfessionalsByCategory: sl(),
        getProfessionalById: sl(),
        getReviewsByProfessional: sl(),
        toggleFavorite: sl(),
        filterProfessionals: sl(),
        addReview: sl(),
        editReview: sl(),
        deleteReview: sl(),
      ));

  // ── Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  sl.registerLazySingleton(() => GetProfessionalsByCategory(sl()));
  sl.registerLazySingleton(() => GetProfessionalById(sl()));
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => SearchProfessionals(sl()));
  sl.registerLazySingleton(() => FilterProfessionals(sl()));
  sl.registerLazySingleton(() => GetReviewsByProfessional(sl()));
  sl.registerLazySingleton(() => AddReview(sl()));
  sl.registerLazySingleton(() => EditReview(sl()));
  sl.registerLazySingleton(() => DeleteReview(sl()));

  // ── Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfessionalsRepository>(
    () => ProfessionalsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Data Sources ──────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProfessionalsRemoteDataSource>(
    () => ProfessionalsRemoteDataSourceImpl(dio: sl()),
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
