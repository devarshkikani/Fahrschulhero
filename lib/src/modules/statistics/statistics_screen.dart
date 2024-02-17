import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/statistics_screen_controller.dart';
import 'package:drive/src/modules/statistics/rank.dart';
import 'package:drive/src/modules/statistics/statistics_details.dart';
import 'package:drive/src/modules/subscription/in_app_purchase.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsScreenController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.getPoints();
    controller.getusersRank();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        centerTitle: true,
        elevation: 0.0,
        title: Obx(() => TextAndStyle(
              title: currentLanguage['stat_stat'],
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(120.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 100,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(
                        () => SizedBox(
                          width: 90,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                currentLanguage['stat_points'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryWhite,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Rubik",
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                controller.points.value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.0,
                                  color: primaryWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 70,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: yellowColor, width: 2),
                        ),
                        child: Image.asset("assets/images/thumb.png"),
                      ),
                      Obx(
                        () => SizedBox(
                          width: 90,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                currentLanguage['home_chapter'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryWhite,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Rubik",
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                (Get.find<HomeController>().doneChapters.length)
                                        .toString() +
                                    '/' +
                                    Get.find<HomeController>()
                                        .allChapters
                                        .length
                                        .toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: primaryWhite,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => Container(
                  color: appBackgroundColor,
                  child: TabBar(
                    labelColor: appColor,
                    controller: controller.topTabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    unselectedLabelColor: primaryBlack,
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                    tabs: [
                      Tab(
                        text: currentLanguage['stat_stat'],
                      ),
                      Tab(
                        text: currentLanguage['stat_rank'],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: controller.topTabController,
            children: [
              StatisticsDetails(),
              RankScreen(),
            ],
          ),
          if (GetStorage().read('isSubscribe') != true)
            Align(
              alignment: Alignment.bottomCenter,
              child: bottomSnackbar(),
            ),
        ],
      ),
    );
  }

  Widget bottomSnackbar() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(bottom: 15, left: 28, right: 28),
      padding: EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: whiteColor.withOpacity(0.6),
      ),
      child: Center(
        child: Obx(
          () => RichText(
            maxLines: 2,
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: currentLanguage['banner_buyPro']
                      .toString()
                      .split('<b>')
                      .first,
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: currentLanguage['banner_buyPro']
                      .toString()
                      .split('<b>')
                      .last
                      .split('</b>')
                      .first,
                  style: TextStyle(
                    color: appColor,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.to(() => SubscriptionScreen());
                    },
                ),
                TextSpan(
                  text: currentLanguage['banner_buyPro']
                      .toString()
                      .split('</b>')
                      .last,
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
