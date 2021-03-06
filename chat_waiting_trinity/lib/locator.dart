import 'package:get_it/get_it.dart';
import './pages/web_old/navigation/navigation_service.dart';

// GetIt locator = GetIt.instance;

// void setupLocator() {
//   locator.registerLazySingleton(() => NavigationService());
// }

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
}