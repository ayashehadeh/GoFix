import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/core/bloc/locale_bloc.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/settings/presentation/pages/profile.dart';
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/features/auth/pages/start_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(BlocProvider(create: (_) => LocaleBloc(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Single HomeBloc instance that lives for the entire app lifetime
    final homeBloc = di.sl<HomeBloc>();

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
            home: const HomePage(),
            routes: {
              '/home': (_) => const HomePage(),
              '/bookings': (_) => BlocProvider(
                    create: (_) => di.sl<BookingsBloc>(),
                    child: const MyBookingsPage(),
                  ),
              '/profile': (_) => const ProfilePage(),
              '/login': (_) => const StartPage(),
            },
          ),
        );
      },
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/core/bloc/locale_bloc.dart';
import 'package:gp/features/auth/pages/start_page.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/settings/presentation/pages/profile.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/injection_container.dart' as di;
import 'package:gp/features/bookings/presentation/bloc/bookings_bloc.dart';
import 'package:gp/features/bookings/presentation/pages/my_bookings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(BlocProvider(create: (_) => LocaleBloc(), child: const MainApp()));
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
          home: const ProfilePage(),
          routes: {
            '/home': (_) => BlocProvider(
              create: (_) => di.sl<HomeBloc>(),
              child: const HomePage(),
            ),
            '/bookings': (_) =>
                const Scaffold(body: Center(child: Text('Bookings'))),
            '/profile': (_) => const ProfilePage(),
            '/login': (_) => const StartPage(),
          },
        );
      },
    );
  }
}
*/