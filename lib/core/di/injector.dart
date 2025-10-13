import 'package:get_it/get_it.dart';
import 'package:trippify/data/repositories/auth_repo.dart';
import 'package:trippify/data/repositories/trip_repo.dart';
import 'package:trippify/data/repositories/user_repo.dart';
import 'package:trippify/data/repositories/friend_repo.dart';
import 'package:trippify/data/repositories/chat_repo.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  locator.registerFactory<AuthRepo>(() => AuthRepoImpl());
  locator.registerFactory<ChatRepo>(() => ChatRepoImpl());
  locator.registerFactory<TripRepo>(() => TripRepoImpl());
  locator.registerFactory<UserRepo>(() => UserRepoImpl());
  locator.registerFactory<FriendRepo>(() => FriendRepoImpl());
}
