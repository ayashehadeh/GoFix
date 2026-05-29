import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/core/bloc/locale_bloc.dart';
import 'package:gp/core/storage/token_storage.dart';
import 'package:gp/core/storage/user_type_storage.dart';
import 'package:gp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/professional_dashboard/presentation/bloc/professional_dashboard_bloc.dart';
import 'package:gp/features/professional_dashboard/presentation/pages/professional_dashboard_screen.dart';
import 'package:gp/features/settings/presentation/pages/profile.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:gp/features/auth/presentation/pages/start_page.dart';
import 'package:gp/core/utils/statuschecker.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await di.init();
  await _registerFcmToken();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleBloc()),
        BlocProvider(create: (_) => di.sl<HomeBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: const MainApp(),
    ),
  );
}

Future<void> _registerFcmToken() async {
  try {
    final isLoggedIn = await TokenStorage.isLoggedIn();
    if (!isLoggedIn) return;

    final token = await TokenStorage.getToken();
    if (token == null) return;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    final dio = Dio(BaseOptions(
      baseUrl: 'https://gofix-api-ceaaewf7hua0ghez.uaenorth-01.azurewebsites.net/api',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ));

    await dio.put('/auth/fcm-token', data: {'fcmToken': fcmToken});
  } catch (_) {}
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, localeState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: localeState.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: const _SplashRouter(),
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
                  child: const ProfessionalDashboardScreen(),
                ),
          },
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
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const StartPage(),
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      );
      return;
    }

    bool isPro;
    try {
      final status = await ProfessionalStatusChecker(di.sl()).checkStatus();
      isPro = status['isProfessional'] == true;
      if (isPro) {
        await UserTypeStorage.setAsProfessional(status['name'] ?? 'Professional');
      } else {
        await UserTypeStorage.clear();
      }
    } catch (_) {
      isPro = await UserTypeStorage.isProfessional();
    }

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      isPro ? '/dashboard' : '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062B54),
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
