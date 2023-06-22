import 'package:abc_barbershop/localization/language_constraints.dart';
import 'package:abc_barbershop/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './pages/auth_page.dart';
import './pages/main_page.dart';
import './pages/splash_screen.dart';
import '../pages/start_page.dart';
import './providers/user_provider.dart';
import './providers/appointment_provider.dart';
import './providers/barber_provider.dart';
import './providers/services_provider.dart';
import './pages/update_profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AppointmentProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ServicesProvider()),
        ChangeNotifierProvider(create: (context) => BarberProvider()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        title: 'BarberShop Booking',
        routes: {
          'home': (BuildContext context) => const MainPage(),
          'start': (BuildContext context) => StartPage(),
          'authPage': (BuildContext context) => AuthPage(false),
          ProfilePage.routeName: (ctx) => const ProfilePage(),
          EditProfilePage.route: (ctx) => const EditProfilePage(),
        },
        theme: ThemeData(
          primaryColor: Colors.white,
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Colors.white,
              onPrimary: Colors.black,
              secondary: Color.fromRGBO(28, 79, 26, 1.0),
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
              background: Colors.white,
              onBackground: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black),
          bottomAppBarTheme: const BottomAppBarTheme(
            color: Color.fromRGBO(28, 79, 26, 1.0),
          ),
        ),
      ),
    );
  }
}
