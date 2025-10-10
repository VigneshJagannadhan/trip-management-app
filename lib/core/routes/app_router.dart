import 'package:trippify/presentation/views/auth/login_view.dart';
import 'package:trippify/presentation/views/auth/register_view.dart';
import 'package:trippify/presentation/views/home/bottom_nav_view.dart';
import 'package:trippify/presentation/views/auth/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String splash = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case LoginView.route:
        return MaterialPageRoute(builder: (_) => LoginView());
      case RegisterView.route:
        return MaterialPageRoute(builder: (_) => RegisterView());
      case HomeView.route:
        return MaterialPageRoute(builder: (_) => const HomeView());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
