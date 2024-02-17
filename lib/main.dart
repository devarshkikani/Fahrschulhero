import 'dart:io';
import 'package:drive/app.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'src/utils/network_dio/network_dio.dart';

List<String> testDeviceIds = [
  'c1fa85da-864c-44d5-9f65-68869c9e38b0',
  '5d9162dd-f57a-421a-166c-4e758556eb63'
];

void mainDelegate(Environment environment) async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  _setupApiEndpoints(environment);
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: testDeviceIds);
  MobileAds.instance.updateRequestConfiguration(configuration);
  InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  await GetStorage.init();
  runApp(DriveApp());
}

void _setupApiEndpoints(Environment environment) {
  locator<ApiEndpoints>().setBaseUrl(environment);
  locator<NetworkDioHttp>()
      .setDynamicHeader(endPoint: locator<ApiEndpoints>().apiEndPoint);
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
