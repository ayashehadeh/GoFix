import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Home
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';

// Profile
import 'package:gp/features/profile.dart';

// Professionals
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/pages/category_professionals_page.dart';

// Bookings
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/my_bookings_page.dart';

// Localization
import 'package:gp/l10n/app_localizations.dart';

// DI
import 'package:gp/injection_container.dart' as di;

// Auth
import 'package:gp/auth/pages/start_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('ar')],

      // ── Starting screen ────────────────────────────────────────────────────
      // Option A: Start from Auth flow (recommended — checks login state)
      home: BlocProvider(
        create: (_) => di.sl<HomeBloc>(),
        child: const HomePage(),
      ),

      // Option B: Go straight to Home (useful during development)
      // home: BlocProvider(
      //   create: (_) => di.sl<HomeBloc>(),
      //   child: const HomePage(),
      // ),

      // ── Named routes ───────────────────────────────────────────────────────
      routes: {
        '/home': (_) => BlocProvider(
          create: (_) => di.sl<HomeBloc>(),
          child: const HomePage(),
        ),
        '/bookings': (_) => BlocProvider(
          create: (_) => di.sl<BookingsBloc>(),
          child: const MyBookingsPage(),
        ),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
