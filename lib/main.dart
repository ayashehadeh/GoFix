import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:gp/injection_container.dart' as di;
import 'auth/pages/start_page.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // set up GetIt dependencies
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

     /* home: BlocProvider(
        create: (_) => di.sl<HomeBloc>(),
        child: const HomePage(),
      ),*/

       home: const StartPage(), // uncomment when switching back to auth flow
    );
  }
}