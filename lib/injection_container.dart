import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/core/storage/token_storage.dart';

// ── Home ──────────────────────────────────────────────────────────────────────
import 'package:gp/features/home/data/data_sources/data_remote_datasource.dart';
import 'package:gp/features/home/domain/use_cases/get_categories_usecase.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

// ── Professionals ─────────────────────────────────────────────────────────────
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

// ── Bookings ──────────────────────────────────────────────────────────────────
import 'package:gp/features/bookings/data/datasources/bookings_remote_datasource.dart';
import 'package:gp/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:gp/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:gp/features/bookings/domain/usecases/get_upcoming_bookings.dart';
import 'package:gp/features/bookings/domain/usecases/get_past_bookings.dart';
import 'package:gp/features/bookings/domain/usecases/get_booking_by_id.dart';
import 'package:gp/features/bookings/domain/usecases/create_booking.dart';
import 'package:gp/features/bookings/domain/usecases/submit_report.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';

// ── Notifications ─────────────────────────────────────────────────────────────
import 'package:gp/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:gp/features/notifications/data/datasources/mock_notifications_datasource.dart';
import 'package:gp/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:gp/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gp/features/notifications/domain/usecases/get_notifications.dart';
import 'package:gp/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:gp/features/notifications/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:gp/features/notifications/presentation/bloc/notifications_bloc.dart';

final sl = GetIt.instance;

/// Set to [true] while developing the UI without a backend.
/// Flip to [false] to switch to the real API implementation.
const bool _useMockNotifications = true;

Future<void> init() async {
  // ── BLoC ──────────────────────────────────────────────────────────────────

  sl.registerFactory(() => HomeBloc(getCategoriesUseCase: sl()));

  sl.registerFactory(
    () => ProfessionalsBloc(
      getProfessionalsByCategory: sl(),
      getProfessionalById: sl(),
      getReviewsByProfessional: sl(),
      toggleFavorite: sl(),
      filterProfessionals: sl(),
      addReview: sl(),
      editReview: sl(),
      deleteReview: sl(),
    ),
  );

  sl.registerFactory(
    () => BookingsBloc(
      getUpcomingBookings: sl(),
      getPastBookings: sl(),
      getBookingById: sl(),
      createBooking: sl(),
      submitReport: sl(),
    ),
  );

  sl.registerFactory(
    () => NotificationsBloc(
      getNotifications: sl(),
      markNotificationAsRead: sl(),
      markAllNotificationsAsRead: sl(),
    ),
  );

  // ── Use Cases — Home ───────────────────────────────────────────────────────

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // ── Use Cases — Professionals ──────────────────────────────────────────────

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

  // ── Use Cases — Bookings ───────────────────────────────────────────────────

  sl.registerLazySingleton(() => GetUpcomingBookings(sl()));
  sl.registerLazySingleton(() => GetPastBookings(sl()));
  sl.registerLazySingleton(() => GetBookingById(sl()));
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => SubmitReport(sl()));

  // ── Use Cases — Notifications ──────────────────────────────────────────────

  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsRead(sl()));

  // ── Repositories ──────────────────────────────────────────────────────────

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfessionalsRepository>(
    () => ProfessionalsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Data Sources ──────────────────────────────────────────────────────────

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProfessionalsRemoteDataSource>(
    () => ProfessionalsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<BookingsRemoteDataSource>(
    () => BookingsRemoteDataSourceImpl(dio: sl()),
  );

  // Notifications datasource — controlled by the flag above.
  // To go live: set _useMockNotifications = false
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => _useMockNotifications
        ? MockNotificationsDataSource()
        : NotificationsRemoteDataSourceImpl(dio: sl()),
  );

  // ── External ──────────────────────────────────────────────────────────────

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl:
            'https://gofix-api-ceaaewf7hua0ghez.uaenorth-01.azurewebsites.net/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            TokenStorage.clear();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  });
}
