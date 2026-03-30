import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/features/home/presentation/bloc/home_bloc.dart';
import 'package:gp/features/home/presentation/pages/home_page.dart';
import 'package:gp/features/professionals/domain/entities/service_category.dart';
import 'package:gp/features/professionals/presentation/bloc/professionals_bloc.dart';
import 'package:gp/features/professionals/presentation/pages/category_professionals_page.dart';
import 'package:gp/features/profile.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/injection_container.dart' as di;

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

      // ── Landing page options (uncomment the one you want) ──────────

      // Option 1: Home page (requires backend)
      // home: BlocProvider(
      //   create: (_) => di.sl<HomeBloc>(),
      //   child: const HomePage(),
      // ),

      // Option 2: Auth flow
      // home: const StartPage(),

      // Option 3: Category professionals page (testing, no auth needed)
      home: BlocProvider(
        create: (_) => di.sl<ProfessionalsBloc>(),
        child: const CategoryProfessionalsPage(
          category: ServiceCategory.plumbing,
        ),
      ),

      routes: {
        '/home': (_) => BlocProvider(
              create: (_) => di.sl<HomeBloc>(),
              child: const HomePage(),
            ),
        '/bookings': (_) => const Scaffold(
              body: Center(child: Text('Bookings')),
            ),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
