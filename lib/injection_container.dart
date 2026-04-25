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
import 'package:gp/features/bookings/data/datasources/mock_bookings_datasource.dart';
import 'package:gp/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:gp/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:gp/features/bookings/domain/usecases/get_upcoming_bookings.dart';
import 'package:gp/features/bookings/domain/usecases/get_past_bookings.dart';
import 'package:gp/features/bookings/domain/usecases/get_booking_by_id.dart';
import 'package:gp/features/bookings/domain/usecases/create_booking.dart';
import 'package:gp/features/bookings/domain/usecases/modify_booking.dart';
import 'package:gp/features/bookings/domain/usecases/cancel_booking.dart';
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

// ── Settings ──────────────────────────────────────────────────────────────────
import 'package:gp/features/settings/data/datasources/account_remote_datasource.dart';
import 'package:gp/features/settings/data/datasources/address_remote_datasource.dart';
import 'package:gp/features/settings/data/datasources/notification_settings_remote_datasource.dart';
import 'package:gp/features/settings/data/datasources/set_password_remote_datasource.dart';
import 'package:gp/features/settings/data/repositories/account_repository_impl.dart';
import 'package:gp/features/settings/data/repositories/address_repository_impl.dart';
import 'package:gp/features/settings/data/repositories/notification_settings_repository_impl.dart';
import 'package:gp/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:gp/features/settings/data/repositories/set_password_repository_impl.dart';
import 'package:gp/features/settings/domain/repositories/account_repository.dart';
import 'package:gp/features/settings/domain/repositories/address_repository.dart';
import 'package:gp/features/settings/domain/repositories/notification_settings_repository.dart';
import 'package:gp/features/settings/domain/repositories/profile_repository.dart';
import 'package:gp/features/settings/domain/repositories/set_password_repository.dart';
import 'package:gp/features/settings/domain/usecases/account_usecases.dart';
import 'package:gp/features/settings/domain/usecases/address_usecases.dart';
import 'package:gp/features/settings/domain/usecases/get_notification_settings_usecase.dart';
import 'package:gp/features/settings/domain/usecases/set_new_password_usecase.dart';
import 'package:gp/features/settings/domain/usecases/update_notification_settings_usecase.dart';
import 'package:gp/features/settings/presentation/bloc/account_bloc.dart';
import 'package:gp/features/settings/presentation/bloc/address_bloc.dart';
import 'package:gp/features/settings/presentation/bloc/notification_settings_bloc.dart';
import 'package:gp/features/settings/presentation/bloc/personal_bloc.dart';
import 'package:gp/features/settings/presentation/bloc/set_password_bloc.dart';

// ── Become Professional ───────────────────────────────────────────────────────
import 'package:gp/features/become_professional/data/datasources/become_professional_remote_datasource.dart';
import 'package:gp/features/become_professional/data/repositories/become_professional_repository_impl.dart';
import 'package:gp/features/become_professional/domain/repositories/become_professional_repository.dart';
import 'package:gp/features/become_professional/domain/usecases/submit_professional_application.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_bloc.dart';

// ── Search ────────────────────────────────────────────────────────────────────
import 'package:gp/features/search/data/datasources/search_remote_datasource.dart';
import 'package:gp/features/search/data/repositories/search_repository_impl.dart';
import 'package:gp/features/search/domain/repositories/search_repository.dart';
import 'package:gp/features/search/domain/usecases/search_usecase.dart';
import 'package:gp/features/search/domain/usecases/get_professionals_by_area.dart';
import 'package:gp/features/search/presentation/bloc/search_bloc.dart';

final sl = GetIt.instance;

// ── Mock flags ────────────────────────────────────────────────────────────────
/// Set to [true] while developing the UI without a running backend.
/// Flip each one independently to [false] when the real API is ready.
const bool _useMockBookings = true;
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
      modifyBooking: sl(),
      cancelBooking: sl(),
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

  sl.registerFactory(
    () => AccountBloc(logout: sl(), deleteAccount: sl(), sendFeedback: sl()),
  );

  sl.registerFactory(
    () => AddressBloc(
      getAddresses: sl(),
      addAddress: sl(),
      updateAddress: sl(),
      deleteAddress: sl(),
    ),
  );

  sl.registerFactory(
    () => NotificationSettingsBloc(
      getNotificationSettings: sl(),
      updateNotificationSettings: sl(),
    ),
  );

  sl.registerFactory(() => PersonalBloc(repository: sl()));

  sl.registerFactory(() => SetPasswordBloc(setNewPassword: sl()));

  // registerFactory so each stepper session gets a fresh BLoC with clean state
  sl.registerFactory(
    () => BecomeProfessionalBloc(submitApplication: sl()),
  );

  // Search — new fresh BLoC per search session (debounce + state management)
  sl.registerFactory(
    () => SearchBloc(searchUseCase: sl(), getProfessionalsByArea: sl()),
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
  sl.registerLazySingleton(() => ModifyBooking(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));
  sl.registerLazySingleton(() => SubmitReport(sl()));

  // ── Use Cases — Notifications ──────────────────────────────────────────────

  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsRead(sl()));

  // ── Use Cases — Settings ───────────────────────────────────────────────────

  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => SendFeedbackUseCase(sl()));
  sl.registerLazySingleton(() => GetAddressesUseCase(sl()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAddressUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAddressUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => SetNewPasswordUseCase(sl()));

  // ── Use Cases — Become Professional ───────────────────────────────────────

  sl.registerLazySingleton(() => SubmitProfessionalApplication(sl()));

  // ── Use Cases — Search ─────────────────────────────────────────────────────

  sl.registerLazySingleton(() => SearchUseCase(sl()));
  sl.registerLazySingleton(() => GetProfessionalsByArea(sl()));

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

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<NotificationSettingsRepository>(
    () => NotificationSettingsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dio: sl()),
  );

  sl.registerLazySingleton<SetPasswordRepository>(
    () => SetPasswordRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<BecomeProfessionalRepository>(
    () => BecomeProfessionalRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Data Sources ──────────────────────────────────────────────────────────

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProfessionalsRemoteDataSource>(
    () => ProfessionalsRemoteDataSourceImpl(dio: sl()),
  );

  // Bookings datasource — set _useMockBookings = false to go live
  sl.registerLazySingleton<BookingsRemoteDataSource>(
    () => _useMockBookings
        ? MockBookingsDataSource()
        : BookingsRemoteDataSourceImpl(dio: sl()),
  );

  // Notifications datasource — set _useMockNotifications = false to go live
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => _useMockNotifications
        ? MockNotificationsDataSource()
        : NotificationsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<NotificationSettingsRemoteDataSource>(
    () => NotificationSettingsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<SetPasswordRemoteDataSource>(
    () => SetPasswordRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<BecomeProfessionalRemoteDataSource>(
    () => BecomeProfessionalRemoteDataSourceImpl(dio: sl()),
  );

  // Search datasource — MockSearchDataSource for frontend; swap when API ready
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => MockSearchDataSource(),
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


/*import 'package:dio/dio.dart';
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
import 'package:gp/features/bookings/data/datasources/mock_bookings_datasource.dart';
import 'package:gp/features/bookings/data/repositories/bookings_repository_impl.dart';
import 'package:gp/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:gp/features/bookings/domain/usecases/get_upcoming_bookings.dart';
import 'package:gp/features/bookings/domain/usecases/get_past_bookings.dart';
import 'package:gp/features/bookings/domain/usecases/get_booking_by_id.dart';
import 'package:gp/features/bookings/domain/usecases/create_booking.dart';
import 'package:gp/features/bookings/domain/usecases/modify_booking.dart';
import 'package:gp/features/bookings/domain/usecases/cancel_booking.dart';
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

// ── Mock flags ────────────────────────────────────────────────────────────────
// Set to [true] while developing the UI without a running backend.
// Flip each one to [false] independently when the real API is ready.

/// Controls the bookings feature mock.
const bool _useMockBookings = true;

/// Controls the notifications feature mock.
const bool _useMockNotifications = true;

// ─────────────────────────────────────────────────────────────────────────────

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
      modifyBooking: sl(),
      cancelBooking: sl(),
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
  sl.registerLazySingleton(() => ModifyBooking(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));
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

  // Bookings datasource — swap flag to go live
  sl.registerLazySingleton<BookingsRemoteDataSource>(
    () => _useMockBookings
        ? MockBookingsDataSource()
        : BookingsRemoteDataSourceImpl(dio: sl()),
  );

  // Notifications datasource — swap flag to go live
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

    // Interceptor — automatically attaches JWT token to every request
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
          // 401 means token expired — clear storage so user gets redirected to login
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
*/