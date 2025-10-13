import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trippify/core/di/injector.dart';
import 'package:trippify/core/providers/app_providers.dart';
import 'package:trippify/core/routes/app_router.dart';
import 'package:trippify/core/theme/app_theme.dart';
import 'package:trippify/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trippify/firebase_options.dart';
import 'package:trippify/presentation/viewmodels/theme_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/language_viewmodel.dart';
import 'presentation/views/auth/splash_screen.dart';
import 'package:trippify/data/repositories/auth_repo.dart';
import 'package:trippify/data/repositories/chat_repo.dart';
import 'package:trippify/data/repositories/friend_repo.dart';
import 'package:trippify/data/repositories/trip_repo.dart';
import 'package:trippify/data/repositories/user_repo.dart';
import 'package:trippify/presentation/viewmodels/auth_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/chat_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/friend_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/trip_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/user_viewmodel.dart';

void main() async {
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseService.initialize();
  setUpLocator();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeViewmodel()),
        ChangeNotifierProvider(create: (context) => LanguageViewmodel()),
        ChangeNotifierProvider(
          create: (context) => AuthViewmodel(authRepo: locator<AuthRepo>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TripViewmodel(tripRepo: locator<TripRepo>()),
        ),
        ChangeNotifierProvider(
          create: (context) => UserViewmodel(userRepo: locator<UserRepo>()),
        ),

        ChangeNotifierProvider(
          create:
              (context) => FriendViewmodel(friendRepo: locator<FriendRepo>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatViewmodel(chatRepo: locator<ChatRepo>()),
        ),
      ],
      child: Consumer2<ThemeViewmodel, LanguageViewmodel>(
        builder: (context, themeVM, langVM, _) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Trippify',
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: SplashView.route,
                theme: appTheme(darkMode: false),
                darkTheme: appTheme(darkMode: true),
                themeMode:
                    themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                locale: langVM.currentLocale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('es'),
                  Locale('de'),
                  Locale('it'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
