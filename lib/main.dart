import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/di/injector.dart';
import 'package:trippify/core/routes/app_router.dart';
import 'package:trippify/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trippify/data/repositories/auth_repo.dart';
import 'package:trippify/data/repositories/trip_repo.dart';
import 'package:trippify/firebase_options.dart';
import 'package:trippify/presentation/viewmodels/auth_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'presentation/views/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setUpLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthViewmodel(authRepo: locator<AuthRepo>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TripViewmodel(tripRepo: locator<TripRepo>()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Trippify',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: SplashView.route,
            theme: appTheme(darkMode: true),
          );
        },
      ),
    );
  }
}
