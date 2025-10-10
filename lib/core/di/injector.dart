import 'package:get_it/get_it.dart';
import 'package:trippify/data/repositories/auth_repo.dart';
import 'package:trippify/data/repositories/trip_repo.dart';

final GetIt locator = GetIt.instance;

void setUpLocator() {
  locator.registerFactory<AuthRepo>(() => AuthRepoImpl());
  locator.registerFactory<TripRepo>(() => TripRepoImpl());
}
