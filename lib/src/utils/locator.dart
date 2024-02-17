import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/dynamic_link_service.dart';
import 'package:drive/src/widgets/common_method.dart';
import 'package:drive/src/widgets/common_widget.dart';
import 'package:drive/src/widgets/user_contacts.dart';
import 'package:get_it/get_it.dart';
import 'internet_error.dart';
import 'network_dio/network_dio.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NetworkDioHttp());
  locator.registerLazySingleton(() => NetworkRepository());
  locator.registerLazySingleton(() => InternetError());
  locator.registerLazySingleton(() => GlobalSingleton());
  locator.registerLazySingleton(() => CommonMethod());
  locator.registerLazySingleton(() => CommonWidget());
  locator.registerLazySingleton(() => ApiEndpoints());
  locator.registerLazySingleton(() => UserContacts());
  locator.registerLazySingleton(() => DynamicRepository());
}
