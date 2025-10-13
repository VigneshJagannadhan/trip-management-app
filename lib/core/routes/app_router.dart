import 'package:trippify/presentation/views/auth/login_view.dart';
import 'package:trippify/presentation/views/auth/register_view.dart';
import 'package:trippify/presentation/views/auth/splash_screen.dart';
import 'package:trippify/presentation/views/home/home_view_tab.dart';
import 'package:trippify/presentation/views/trip_detail/trip_detail_view.dart';
import 'package:trippify/presentation/views/profile/profile_edit_view.dart';
import 'package:trippify/presentation/views/subscription/subscription_view.dart';
import 'package:trippify/presentation/views/chat/chat_screen.dart';
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
      case HomeViewTab.route:
        return MaterialPageRoute(builder: (_) => const HomeViewTab());
      case TripDetailView.route:
        final tripId = settings.arguments as String?;
        if (tripId == null) {
          return MaterialPageRoute(
            builder:
                (_) => const Scaffold(
                  body: Center(child: Text('Trip ID is required')),
                ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TripDetailView(tripId: tripId),
        );
      case ProfileEditView.route:
        return MaterialPageRoute(builder: (_) => const ProfileEditView());
      case SubscriptionView.route:
        return MaterialPageRoute(builder: (_) => const SubscriptionView());
      case ChatScreen.route:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('tripId') ||
            !args.containsKey('tripName')) {
          return MaterialPageRoute(
            builder:
                (_) => const Scaffold(
                  body: Center(child: Text('Trip info required')),
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                tripId: args['tripId'] as String,
                tripName: args['tripName'] as String,
              ),
        );

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
