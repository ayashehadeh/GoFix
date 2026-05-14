import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/core/bloc/locale_bloc.dart';
import 'package:gp/core/storage/token_storage.dart';
import 'package:gp/core/storage/user_type_storage.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_bloc.dart';
import 'package:gp/features/professional_dashboard/presentation/pages/professional_dashboard_screen.dart';
import 'package:gp/features/settings/presentation/pages/profile.dart';
import 'package:gp/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await di.init();

  // Send FCM token to backend if user is logged in
  await _registerFcmToken();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleBloc()),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
      ],
      child: const MainApp(),
    ),
  );
}

/// Gets the FCM token and sends it to the backend.
Future<void> _registerFcmToken() async {
  try {
    final isLoggedIn = await TokenStorage.isLoggedIn();
    if (!isLoggedIn) return;

    final token = await TokenStorage.getToken();
    if (token == null) return;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    final dio = Dio(BaseOptions(
      baseUrl:
          'https://gofix-api-ceaaewf7hua0ghez.uaenorth-01.azurewebsites.net/api',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));

    await dio.put('/auth/fcm-token', data: {'fcmToken': fcmToken});
  } catch (_) {
    // Don't crash the app if FCM token registration fails
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        return BlocProvider.value(
          value: homeBloc,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: localeState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
            // EVERYONE starts at StartPage (login)
            home: const StartPage(),
            routes: {
              '/home': (_) => const HomePage(),
              '/bookings': (_) => BlocProvider(
                    create: (_) => di.sl<BookingsBloc>(),
                    child: const MyBookingsPage(),
                  ),
              '/profile': (_) => const ProfilePage(),
              '/login': (_) => const StartPage(),
              '/dashboard': (_) => BlocProvider(
                    create: (_) => di.sl<ProfessionalDashboardBloc>(),
                    child: const ProfessionalDashboardScreen(
                      professionalName: 'Hazim',
                    ),
                  ),
            },
          ),
        );
      },
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final isLoggedIn = await TokenStorage.isLoggedIn();
    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final isProfessional = await UserTypeStorage.isProfessional();
    if (!mounted) return;

    if (isProfessional) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A3A5C),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
