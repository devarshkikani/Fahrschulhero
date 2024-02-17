import 'dart:async';

import 'package:drive/main_home_screen.dart';
import 'package:drive/src/modules/login/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'src/controller/language_controller.dart';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/binding/main_home_screen_binding.dart';
import 'package:drive/src/modules/settings/class_screen.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:get_storage/get_storage.dart';
import 'package:drive/src/utils/locator.dart';

import 'src/controller/main_home_controller.dart';
import 'src/repository/network_repository.dart';

class IntroScreen extends StatefulWidget {
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  final GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  final LanguageController languageController = Get.put(LanguageController());
  GetStorage getStorage = GetStorage();

  @override
  void initState() {
    Timer(Duration(milliseconds: 1500), navigationPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        alignment: Alignment.center,
        child: Image.asset("assets/images/logo.png"),
      ),
    );
  }

  void navigationPage() async {
    bool? status = getStorage.read('isLoggedIn');
    String? authToken = getStorage.read('token');
    String? refreshToken = getStorage.read('refreshToken');
    final response = await _networkRepository.getConfigurations(null);
    if (response != null && response['statusCode'] == 200) {
      getStorage.write('questionVersion', response['data']['questionVersion']);
      getStorage.write(
          'adBannerTimeoutSeconds', response['data']['adBannerTimeoutSeconds']);
      GlobalSingleton.globalSingleton.adsSeconds =
          int.parse(response['data']['adBannerTimeoutSeconds']);
      getStorage.write(
          'interstitialAdPage', response['data']['adAfterNoQuestions']);
      GlobalSingleton.globalSingleton.interstitialAdPage =
          int.parse(response['data']['adAfterNoQuestions']);
      await setTranslations(status, authToken, refreshToken,
          response['data']['translationVersion']);
    }
  }

  Future setTranslations(
      status, authToken, refreshToken, translationsVersion) async {
    if (getStorage.read('translation') != null &&
        translationsVersion == getStorage.read('translationVersion')) {
      languageController
          .changeCurrentLanguage(getStorage.read('language') ?? 'de');
      navihationToPage(status, authToken, refreshToken);
    } else {
      Map translation = {};
      Map enTranslationsData =
          await _networkRepository.getTranslations(null, 'en');
      Map deTranslationsData =
          await _networkRepository.getTranslations(null, 'de');
      if (deTranslationsData.isNotEmpty && enTranslationsData.isNotEmpty) {
        translation['en'] = enTranslationsData;
        translation['de'] = deTranslationsData;
        getStorage.write('translation', translation);
        getStorage.write('language', 'de');
        getStorage.write('translationVersion', translationsVersion);
        languageController.changeCurrentLanguage('de');
        navihationToPage(status, authToken, refreshToken);
      }
    }
  }

  navihationToPage(status, authToken, refreshToken) {
    if (_globalSingleton.initialRedirect == true) {
      if (status == true &&
          (authToken != null && authToken != '') &&
          (refreshToken != null && refreshToken != '')) {
        if (getStorage.read('classId') != null) {
          pageIndex.value = 0;
          Get.offAll(() => MainHomeScreen(), binding: MainHomeBinding());
        } else {
          Get.offAll(
            () => ClassScreen(
              isformLogin: true,
            ),
          );
        }
      } else {
        Get.offAll(
          () => SignupScreen(),
          binding: AuthenticationBinding(),
        );
      }
    }
  }
}
