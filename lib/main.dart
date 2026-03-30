import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/profile.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/pages/category_professionals_page.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/injection_container.dart' as di;
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

      // ── Landing page ──────────────────────────────────────────────
      // Option 1: Home page (requires backend + auth token)
      home: BlocProvider(
        create: (_) => di.sl<HomeBloc>(),
        child: const HomePage(),
      ),

      // Option 2: Auth flow (uncomment to start from sign-in)
      // home: const StartPage(),
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


/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/profile.dart';
import 'package:gp/auth/become_professional/pages/professional_details1.dart';

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

      home: BlocProvider(
        create: (_) => di.sl<HomeBloc>(),
        child: const HomePage(),
      ),

      routes: {
        '/home': (_) => BlocProvider(
          create: (_) => di.sl<HomeBloc>(),
          child: const HomePage(),
        ),
        '/bookings': (_) => const Scaffold(
          body: Center(child: Text('Bookings')),
        ), // replace with your BookingsPage
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
*/