import 'dart:async';
import 'dart:io';

import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds extends StatefulWidget {
  const GoogleAds({Key? key}) : super(key: key);

  @override
  _GoogleAdsState createState() => _GoogleAdsState();
}

RxBool adShaw = false.obs;

class _GoogleAdsState extends State<GoogleAds> {
  BannerAd? bannerAds;
  RxBool isAdLoaded = false.obs;
  Timer? adsTimer;
  RxInt adsTimerCount = 0.obs;
  final GlobalSingleton _globalSingleton = locator<GlobalSingleton>();

  @override
  void initState() {
    super.initState();
    if (!Get.find<HomeController>().isSubscribe.value) {
      adsInit();
      adsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (adsTimerCount.value >= _globalSingleton.adsSeconds) {
          adsTimerCount.value = 0;
          adsInit();
        } else {
          adsTimerCount.value++;
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    bannerAds?.dispose();
    adsTimer?.cancel();
  }

  void adsInit() {
    bannerAds?.dispose();
    isAdLoaded.value = false;
    if (adShaw.value == false) {
      Future.delayed(Duration(milliseconds: 0), () {
        Get.find<QuestionScreenController>().isShowingAds.value = false;
      });
    }
    bannerAds = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ads) {
          Get.find<QuestionScreenController>().isShowingAds.value = true;
          isAdLoaded.value = true;
          adShaw.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          adShaw.value = false;
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    bannerAds?.load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => isAdLoaded.value
          ? Container(
              child: AdWidget(ad: bannerAds!),
              width: bannerAds!.size.width.toDouble(),
              margin: EdgeInsets.only(bottom: 10.0),
              height: 55.0,
            )
          : SizedBox(
              height:
                  adShaw.value && !Get.find<HomeController>().isSubscribe.value
                      ? 65.0
                      : 0,
            ),
    );
  }
}

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4716968301608553/3479915475';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4716968301608553/1118579667';
    }
    throw new UnsupportedError("Unsupported platform");
  }
}
