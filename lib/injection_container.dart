import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:gp/features/become_professional/domain/usecases/update_profile.dart';
import 'package:gp/features/bookings/domain/usecases/submit_payment_amount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gp/core/storage/token_storage.dart';
import 'package:gp/features/become_professional/domain/usecases/get_cities.dart';
import 'package:gp/features/become_professional/domain/usecases/set_service_areas.dart';
import 'package:gp/features/become_professional/domain/usecases/set_working_hours.dart';

//earnings
import 'package:gp/features/earnings/presentation/bloc/earnings_bloc.dart';
import 'package:gp/features/earnings/domain/usecases/earnings_usecases.dart';
import 'package:gp/features/earnings/domain/repositories/earnings_repository.dart';
import 'package:gp/features/earnings/data/repositories/earnings_repository_impl.dart';
import 'package:gp/features/earnings/data/datasources/earnings_remote_datasource.dart';
// ── Home ──────────────────────────────────────────────────────────────────────
import 'package:gp/features/home/data/data_sources/data_remote_datasource.dart';
import 'package:gp/features/home/domain/use_cases/get_categories_usecase.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

// ── Favorites ─────────────────────────────────────────────────────────────────
import 'package:gp/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:gp/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:gp/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:gp/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:gp/features/favorites/presentation/bloc/favorites_bloc.dart';

// ── Chat ──────────────────────────────────────────────────────────────────────
import 'package:gp/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:gp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:gp/features/chat/domain/repositories/chat_repository.dart';
import 'package:gp/features/chat/domain/usecases/chat_usecases.dart';
import 'package:gp/features/chat/presentation/bloc/chat_bloc.dart';

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
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_my_profile.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_professional_by_id.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_professionals_by_category.dart';
import 'package:gp/features/professionals/domain/usecases/profeessional_usecases/get_service_areas_by_professional.dart';
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
import 'package:gp/features/bookings/domain/usecases/confirm_payment.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/bloc/active_booking_cubit.dart';

// ── Notifications ─────────────────────────────────────────────────────────────
import 'package:gp/features/notifications/data/datasources/notifications_remote_datasource.dart';
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
import 'package:gp/features/become_professional/data/datasources/application_status_remote_datasource.dart';
import 'package:gp/features/become_professional/data/repositories/become_professional_repository_impl.dart';
import 'package:gp/features/become_professional/data/repositories/application_status_repository_impl.dart';
import 'package:gp/features/become_professional/domain/repositories/become_professional_repository.dart';
import 'package:gp/features/become_professional/domain/repositories/application_status_repository.dart';
import 'package:gp/features/become_professional/domain/usecases/get_categories.dart';
import 'package:gp/features/become_professional/domain/usecases/get_service_areas.dart';
import 'package:gp/features/become_professional/domain/usecases/get_services_for_category.dart';
import 'package:gp/features/become_professional/domain/usecases/create_profile.dart';
import 'package:gp/features/become_professional/domain/usecases/set_services.dart';
import 'package:gp/features/become_professional/domain/usecases/upload_profile_picture.dart';
import 'package:gp/features/become_professional/domain/usecases/upload_document.dart';
import 'package:gp/features/become_professional/domain/usecases/submit_application.dart';
import 'package:gp/features/become_professional/domain/usecases/get_application_status.dart';
import 'package:gp/features/become_professional/presentation/bloc/become_professional_bloc.dart';
import 'package:gp/features/become_professional/presentation/bloc/application_status_bloc.dart';

// ── Search ────────────────────────────────────────────────────────────────────
import 'package:gp/features/search/data/datasources/search_remote_datasource.dart';
import 'package:gp/features/search/data/repositories/search_repository_impl.dart';
import 'package:gp/features/search/domain/repositories/search_repository.dart';
import 'package:gp/features/search/domain/usecases/search_usecase.dart';
import 'package:gp/features/search/presentation/bloc/search_bloc.dart';

// ── Professional Dashboard ────────────────────────────────────────────────────
import 'package:gp/features/professional_dashboard/data/datasources/professional_dashboard_remote_datasource.dart';
import 'package:gp/features/professional_dashboard/data/datasources/mock_professional_dashboard_datasource.dart';
import 'package:gp/features/professional_dashboard/data/repositories/professional_dashboard_repository_impl.dart';
import 'package:gp/features/professional_dashboard/domain/repositories/professional_dashboard_repository.dart';
import 'package:gp/features/professional_dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_bloc.dart';

// ── Professional Availability ─────────────────────────────────────────────────
import 'package:gp/features/professional_availability/data/datasources/availability_local_datasource.dart';
import 'package:gp/features/professional_availability/data/repositories/availability_repository_impl.dart';
import 'package:gp/features/professional_availability/domain/repositories/availability_repository.dart';
import 'package:gp/features/professional_availability/domain/usecases/get_availability.dart';
import 'package:gp/features/professional_availability/domain/usecases/save_availability.dart';
import 'package:gp/features/professional_availability/presentation/bloc/availability_bloc.dart';
import 'package:gp/features/professional_availability/data/datasources/availability_remote_datasource.dart';

//auth
import 'package:gp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gp/features/auth/domain/repositories/auth_repository.dart';
import 'package:gp/features/auth/domain/usecases/auth_usecases.dart';
import 'package:gp/features/auth/presentation/bloc/auth_bloc.dart';

//prof jobs
import 'package:gp/features/professional_jobs/data/datasources/professional_jobs_datasource.dart';
import 'package:gp/features/professional_jobs/data/repositories/professional_jobs_repository_impl.dart';
import 'package:gp/features/professional_jobs/domain/repositories/professional_jobs_repository.dart';
import 'package:gp/features/professional_jobs/domain/usecases/professional_jobs_usecases.dart';
import 'package:gp/features/professional_jobs/presentation/bloc/professional_jobs_bloc.dart';

final sl = GetIt.instance;

const bool _useMockBookings = false;
const bool _useMockFavorites = false;
const bool _useMockChat = false;
const bool _useMockProfessionalDashboard = false;

Future<void> init() async {
  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerFactory(() => AuthBloc(
        login: sl(),
        register: sl(),
        forgotPassword: sl(),
        resetPassword: sl(),
      ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory(() => HomeBloc(getCategoriesUseCase: sl()));

  sl.registerFactory(() => EarningsBloc(
        getEarnings: sl(),
        refreshEarnings: sl(),
      ));

  sl.registerFactory(
    () => ProfessionalsBloc(
      getProfessionalsByCategory: sl(),
      getProfessionalById: sl(),
      getMyProfile: sl(),
      getServiceAreasByProfessional: sl(),
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
      confirmPayment: sl(),
    ),
  );

  sl.registerFactory(
    () => ActiveBookingCubit(getUpcomingBookings: sl()),
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
  sl.registerFactory(() => SetPasswordBloc(verifyCurrentPassword: sl(), setNewPassword: sl()));
  sl.registerFactory(() => ApplicationStatusBloc(getApplicationStatus: sl()));

  sl.registerFactory(
    () => BecomeProfessionalBloc(
      getCategories: sl(),
      getServiceAreas: sl(),
      getServicesForCategory: sl(),
      createProfile: sl(),
      updateProfile: sl(),
      setServices: sl(),
      setServiceAreas: sl(),
      uploadProfilePicture: sl(),
      uploadDocument: sl(),
      submitApplication: sl(),
      getCitiesFromProfessional: sl(),
    ),
  );

  sl.registerFactory(
    () => SearchBloc(
      searchUseCase: sl(),
      getProfessionalsByArea: sl(),
      getRecentSearches: sl(),
      recordSearch: sl(),
      deleteRecentSearch: sl(),
      clearRecentSearches: sl(),
    ),
  );

  sl.registerFactory(
    () => FavoritesBloc(
      getFavoritesList: sl(),
      addFavorite: sl(),
      removeFavorite: sl(),
      isFavorite: sl(),
    ),
  );

  sl.registerFactory(
    () => ChatBloc(
      getChats: sl(),
      getMessages: sl(),
      sendMessage: sl(),
      deleteChat: sl(),
      getOrCreateChat: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfessionalDashboardBloc(
      getDashboardStats: sl(),
      getIncomingRequests: sl(),
      getScheduledJobs: sl(),
      acceptJobRequest: sl(),
      declineJobRequest: sl(),
      updateJobStatus: sl(),
      submitPaymentAmount: sl(),
    ),
  );

  sl.registerFactory(
    () => AvailabilityBloc(
      getAvailability: sl(),
      saveWorkingHours: sl(),
      toggleAvailability: sl(),
    ),
  );

  sl.registerFactory(() => ProfessionalJobsBloc(
        getUpcomingJobs: sl(),
        getPastJobs: sl(),
        updateJobStatus: sl(),
      ));

  // ── Use Cases — Home ───────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // ── Use Cases — Earnings ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetEarnings(sl()));
  sl.registerLazySingleton(() => RefreshEarnings(sl()));

  // ── Use Cases — Professionals ──────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProfessionalsByCategory(sl()));
  sl.registerLazySingleton(() => GetProfessionalById(sl()));
  sl.registerLazySingleton(() => GetMyProfile(sl()));
  sl.registerLazySingleton(() => GetServiceAreasByProfessional(sl()));
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
  sl.registerLazySingleton(() => ConfirmPayment(sl()));
  sl.registerLazySingleton(() => SubmitPaymentAmount(sl()));

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
  sl.registerLazySingleton(() => VerifyCurrentPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SetNewPasswordUseCase(sl()));

  // ── Use Cases — Become Professional ────────────────────────────────────────
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetServiceAreas(sl()));
  sl.registerLazySingleton(() => GetServicesForCategory(sl()));
  sl.registerLazySingleton(() => CreateProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => SetServices(sl()));
  sl.registerLazySingleton(() => SetServiceAreas(sl()));
  sl.registerLazySingleton(() => SetWorkingHours(sl()));
  sl.registerLazySingleton(() => UploadProfilePicture(sl()));
  sl.registerLazySingleton(() => UploadDocument(sl()));
  sl.registerLazySingleton(() => SubmitApplication(sl()));
  sl.registerLazySingleton(() => GetCitiesFromProfessional(sl()));
  sl.registerLazySingleton(() => GetApplicationStatus(sl()));

  // ── Use Cases — Search ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SearchUseCase(sl()));
  sl.registerLazySingleton(() => GetProfessionalsByArea(sl()));
  sl.registerLazySingleton(() => GetRecentSearchesUseCase(sl()));
  sl.registerLazySingleton(() => RecordSearchUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecentSearchUseCase(sl()));
  sl.registerLazySingleton(() => ClearRecentSearchesUseCase(sl()));

  // ── Use Cases — Favorites ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetFavoritesList(sl()));
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));

  // ── Use Cases — Chat ───────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetChats(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => DeleteChat(sl()));
  sl.registerLazySingleton(() => GetOrCreateChat(sl()));

  // ── Use Cases — Professional Dashboard ─────────────────────────────────────
  sl.registerLazySingleton(() => GetDashboardStats(sl()));
  sl.registerLazySingleton(() => GetIncomingRequests(sl()));
  sl.registerLazySingleton(() => GetScheduledJobs(sl()));
  sl.registerLazySingleton(() => AcceptJobRequest(sl()));
  sl.registerLazySingleton(() => DeclineJobRequest(sl()));
  sl.registerLazySingleton(() => UpdateJobStatus(sl()));

  // ── Use Cases — Professional Availability ──────────────────────────────────
  sl.registerLazySingleton(() => GetAvailability(sl()));
  sl.registerLazySingleton(() => SaveWorkingHours(sl()));
  sl.registerLazySingleton(() => ToggleAvailability(sl()));

  // ── Use Cases — Professional Jobs ──────────────────────────────────────────
  sl.registerLazySingleton(() => GetUpcomingJobs(sl()));
  sl.registerLazySingleton(() => GetPastJobs(sl()));
  sl.registerLazySingleton(() => UpdateProJobStatus(sl()));

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(
      remoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<ProfessionalsRepository>(() => ProfessionalsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ReviewsRepository>(() => ReviewsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<BookingsRepository>(() => BookingsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(sl()));
  sl.registerLazySingleton<AddressRepository>(() => AddressRepositoryImpl(sl()));
  sl.registerLazySingleton<NotificationSettingsRepository>(() => NotificationSettingsRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(dio: sl()));
  sl.registerLazySingleton<SetPasswordRepository>(() => SetPasswordRepositoryImpl(sl()));
  sl.registerLazySingleton<BecomeProfessionalRepository>(
      () => BecomeProfessionalRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ApplicationStatusRepository>(() => ApplicationStatusRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<ProfessionalDashboardRepository>(
      () => ProfessionalDashboardRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AvailabilityRepository>(() => AvailabilityRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));
  sl.registerLazySingleton<ProfessionalJobsRepository>(
    () => ProfessionalJobsRepositoryImpl(remoteDataSource: sl()),
  );

  // ── Data Sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(dio: sl()));

  sl.registerLazySingleton<EarningsRemoteDataSource>(
    () => EarningsRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProfessionalsRemoteDataSource>(() => ProfessionalsRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<BookingsRemoteDataSource>(
    () => _useMockBookings ? MockBookingsDataSource() : BookingsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AccountRemoteDataSource>(() => AccountRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AddressRemoteDataSource>(() => AddressRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<NotificationSettingsRemoteDataSource>(
      () => NotificationSettingsRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<SetPasswordRemoteDataSource>(() => SetPasswordRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<BecomeProfessionalRemoteDataSource>(() => BecomeProfessionalRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<ApplicationStatusRemoteDataSource>(() => ApplicationStatusRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<SearchRemoteDataSource>(() => SearchRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => _useMockFavorites ? MockFavoritesDataSource() : FavoritesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => _useMockChat ? MockChatDataSource() : ChatRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProfessionalDashboardRemoteDataSource>(
    () => _useMockProfessionalDashboard
        ? MockProfessionalDashboardDataSource()
        : ProfessionalDashboardRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AvailabilityRemoteDataSource>(
      () => AvailabilityRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AvailabilityLocalDataSource>(
      () => AvailabilityLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<ProfessionalJobsRemoteDataSource>(
      () => ProfessionalJobsRemoteDataSourceImpl(dio: sl()));

  // ── External ──────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://gofix-api-ceaaewf7hua0ghez.uaenorth-01.azurewebsites.net/api',
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
