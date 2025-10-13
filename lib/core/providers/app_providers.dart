import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:trippify/core/di/injector.dart';
import 'package:trippify/presentation/viewmodels/theme_viewmodel.dart';
import 'package:trippify/presentation/viewmodels/language_viewmodel.dart';
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

List<SingleChildWidget> get getProviders {
  return [
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
      create: (context) => FriendViewmodel(friendRepo: locator<FriendRepo>()),
    ),
    ChangeNotifierProvider(
      create: (context) => ChatViewmodel(chatRepo: locator<ChatRepo>()),
    ),
  ];
}
