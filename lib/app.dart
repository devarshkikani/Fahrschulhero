import 'dart:convert';
import 'dart:io';
import 'package:drive/main_home_screen.dart';
import 'package:drive/splash_screen.dart';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/binding/main_home_screen_binding.dart';
import 'package:drive/src/modules/login/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/network_dio/network_dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'src/controller/main_home_controller.dart';
import 'src/controller/statistics_screen_controller.dart';
import 'src/utils/dynamic_link_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(debugLabel: "navigator");

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class DriveApp extends StatefulWidget {
  @override
  State<DriveApp> createState() => _DriveAppState();
}

class _DriveAppState extends State<DriveApp> {
  final GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  final NetworkDioHttp _networkDioHttp = locator<NetworkDioHttp>();
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();
  final GetStorage getStorage = GetStorage();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  @override
  void initState() {
    super.initState();
    rebuildFcm();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fahrschulhero',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: "CeraPro",
      ),
      home: IntroScreen(),
    );
  }

  rebuildFcm() async {
    FirebaseMessaging.instance.getToken().then((deviceToken) {
      setToken(deviceToken ?? '');
    });

    var initSetttings = InitializationSettings(
        android: android, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (Platform.isIOS) {
        await showNotification(
          message!.notification!.title.toString(),
          message.notification!.body.toString(),
          json.encode(message.data),
        );
      }
      if (Platform.isAndroid) {
        String? title = message!.notification?.title;
        String? body = message.notification?.body;
        if (title != null && body != null) {
          await showNotification(
            title,
            body,
            json.encode(message.data),
          );
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (Platform.isIOS) {
        onSelectNotification(json.encode(message!.data));
      } else {
        onSelectNotification(json.encode(message!.data));
      }
    });
  }

  setToken(String? deviceToken) async {
    _globalSingleton.deviceToken = deviceToken.toString();
    await _networkDioHttp.setDynamicHeader(endPoint: _appConstants.apiEndPoint);
    print('deviceToken : ${deviceToken.toString()}');
    await tempDynamic();
  }

  Future showNotification(String title, String message, dynamic payload) async {
    var android = AndroidNotificationDetails(
      'channel id',
      'channel NAME',
      channelDescription: 'CHANNEL DESCRIPTION',
      priority: Priority.high,
      importance: Importance.max,
      playSound: true,
    );

    var iOS = IOSNotificationDetails();

    var platform = NotificationDetails(iOS: iOS, android: android);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platform,
      payload: payload,
    );
  }

  Future onSelectNotification(String? payloadData) async {
    dynamic payload = await json.decode(payloadData ?? '');
    if (GetStorage().read('userId') != null) {
      if (payload['screenRedirect'] == 'Home') {
        pageIndex.value = 0;
        Get.offAll(
          () => MainHomeScreen(),
          binding: MainHomeBinding(),
        );
      } else if (payload['screenRedirect'] == 'Training') {
        pageIndex.value = 1;
        Get.offAll(
          () => MainHomeScreen(),
          binding: MainHomeBinding(),
        );
      } else if (payload['screenRedirect'] == 'Schools') {
        // pageIndex.value = 2;
        // pageIndex.value = 0;
        Get.offAll(
          () => MainHomeScreen(),
          binding: MainHomeBinding(),
        );
      } else if (payload['screenRedirect'] == 'Statistics.Default') {
        pageIndex.value = 2;
        tabIndex.value = 0;
        Get.offAll(
          () => MainHomeScreen(),
          binding: MainHomeBinding(),
        );
      } else if (payload['screenRedirect'] == 'Statistics.Rank') {
        pageIndex.value = 2;
        tabIndex.value = 1;
        Get.offAll(
          () => MainHomeScreen(),
          binding: MainHomeBinding(),
        );
      } else if (payload['screenRedirect'] == 'Profile') {
        pageIndex.value = 3;
        Get.offAll(
          () => MainHomeScreen(),
          binding: MainHomeBinding(),
        );
      }
    } else {
      Get.offAll(
        () => SignupScreen(),
        binding: AuthenticationBinding(),
      );
    }
  }

  tempDynamic() async {
    await locator<DynamicRepository>().initDynamicLinks();
  }
}
