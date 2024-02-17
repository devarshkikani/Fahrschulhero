import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/statistics_screen_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/subscription/in_app_purchase.dart';
import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomeScreen extends GetView<HomeController> {
  final _textScreenController = Get.put(QuestionScreenController());
  final StatisticsScreenController staisticsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(initState: (data) async {
        await controller.getChapter(context: context);
        await staisticsController.getusersRank();
      }, builder: (_) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: Get.height,
              width: Get.width,
              alignment: Alignment(0.8, -0.8),
              color: appColor,
              padding: EdgeInsets.zero,
              child: Obx(
                () => !controller.isSubscribe.value
                    ? GestureDetector(
                        onTap: () {
                          if (!isInternetOn.value) {
                            showSnackBar(
                              title: currentLanguage['noti_netErrorTitle'],
                              message: currentLanguage['noti_netErrorSubtitle'],
                              backgroundColor: appColor,
                              colorText: whiteColor,
                              margin: EdgeInsets.all(30),
                            );
                          } else {
                            tryPlus(context);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          decoration: BoxDecoration(
                            color: lightWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: TextAndStyle(
                            title: currentLanguage['home_tryPlus'],
                            color: whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : SizedBox(),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: Get.height * 0.17),
              width: Get.width,
              padding: EdgeInsets.fromLTRB(28, 46, 28, 0),
              decoration: BoxDecoration(
                color: lightWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextAndStyle(
                    title: '${controller.getStorage.read('firstName')}',
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0,
                  ),
                  Obx(
                    () => !controller.isSubscribe.value
                        ? TextAndStyle(
                            title: currentLanguage['home_basicMember'],
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.0,
                            letterSpacing: 1.5)
                        : TextAndStyle(
                            title: currentLanguage['home_plusMember'],
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.0,
                            letterSpacing: 1.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 23.5, bottom: 11),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(() => Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextAndStyle(
                                    title: currentLanguage['home_points'],
                                    color: appColor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Rubik",
                                    letterSpacing: 2.0,
                                    fontSize: 12,
                                  ),
                                  TextAndStyle(
                                    fontWeight: FontWeight.w700,
                                    title: controller.points.value.toString(),
                                    fontSize: 24.0,
                                  ),
                                ],
                              )),
                          VerticalDivider(
                            color: greyColor,
                            width: 2.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Obx(() => TextAndStyle(
                                    title: currentLanguage['home_chapter'],
                                    color: appColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    letterSpacing: 2.0,
                                    fontFamily: "Rubik",
                                  )),
                              TextAndStyle(
                                title:
                                    "${controller.doneChapters.length}/${controller.allChapters.length}",
                                fontWeight: FontWeight.w700,
                                fontSize: 24.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: Get.width,
                    child: FlutterSlider(
                      values: [
                        controller.allChapters.length > 0
                            ? double.parse(controller.allChapters
                                .where((e) =>
                                    e['totalQuestions'] == e['correctAnswered'])
                                .toList()
                                .length
                                .toString())
                            : 0.0
                      ],
                      max: controller.allChapters.length > 0
                          ? double.parse(
                              controller.allChapters.length.toString())
                          : 100.0,
                      min: 0,
                      visibleTouchArea: false,
                      disabled: true,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tooltip: FlutterSliderTooltip(
                        disabled: true,
                      ),
                      trackBar: FlutterSliderTrackBar(
                        activeDisabledTrackBarColor: appColor,
                        activeTrackBarHeight: 8,
                        inactiveTrackBarHeight: 8,
                        activeTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        inactiveTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      handler: FlutterSliderHandler(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Container(
                            decoration: BoxDecoration(
                              color: appColor.withOpacity(0.20),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(2),
                            child: Image.asset(
                              "assets/images/thumb.png",
                            )),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: Get.width >= 500 ? 500 : Get.width,
                        child: ListView.builder(
                          itemCount: controller.levelList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                                child:
                                    levelListView(controller.levelList[index]));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 28.0,
              top: Get.height * 0.10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  height: 83,
                  width: 83,
                  child: controller.getStorage.read('photoUrl').toString() !=
                          'null'
                      ? CachedNetworkImage(
                          imageUrl: '${controller.getStorage.read('photoUrl')}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Center(child: const CupertinoActivityIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image.asset(
                          "assets/images/default/profile.jpeg",
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void tryPlus(context) {
    Get.to(() => SubscriptionScreen())?.then((value) {
      controller.getChapter();
    });
  }

  double circleProgressValue(int index) {
    return (controller.chapterIndex.value >= index
            ? int.parse(controller.allChapters[index]['correctAnswered']) /
                int.parse(controller.allChapters[index]['totalQuestions'])
            : 0.0) *
        100;
  }

  Widget levelListView(int rowCount) {
    return Container(
      height: Get.width <= 415
          ? Get.width <= 405
              ? 145
              : 140
          : 145,
      alignment: (rowCount + 1) == controller.allChapters.length ||
              (rowCount + 2) == controller.allChapters.length
          ? rowCount.isOdd
              ? Alignment.centerRight
              : Alignment.centerLeft
          : Alignment.center,
      child: Directionality(
        textDirection: rowCount.isOdd ? TextDirection.rtl : TextDirection.ltr,
        child: ListView.builder(
          itemCount: (rowCount + 2) == controller.allChapters.length
              ? 2
              : (rowCount + 1) == controller.allChapters.length
                  ? 1
                  : 3,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          onChapterClick((rowCount + index), context);
                        },
                        child: Column(
                          children: [
                            circularProgress(rowCount + index, context),
                            chapterNameText(rowCount + index),
                            ((index + 1) % 3 == 0)
                                ? (index + rowCount + 1) ==
                                        controller.listSize.value
                                    ? SizedBox()
                                    : SvgPicture.asset(
                                        "assets/icons/svg_icons/arrow_down.svg",
                                        color: controller.chapterIndex.value >=
                                                (rowCount + index + 1)
                                            ? appColor
                                            : darkGrey,
                                      )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      controller.chapterIndex.value >= rowCount + index ||
                              (rowCount + index == 0 ? true : false)
                          ? SizedBox()
                          : Positioned(
                              right: 7,
                              top: 2,
                              child: SvgPicture.asset(
                                "assets/images/lock.svg",
                              ),
                            ),
                    ],
                  ),
                  index == 0 || index == 1
                      ? (index + rowCount + 1) == controller.allChapters.length
                          ? SizedBox()
                          : Container(
                              height: 66,
                              // width: Get.width <= 400
                              //     ? Get.width <= 380
                              //         ? Get.width <= 370
                              //             ? Get.width * 0.057
                              //             : Get.width * 0.072
                              //         : Get.width <= 390
                              //             ? Get.width * 0.088
                              //             : Get.width * 0.095
                              //     : Get.width <= 410
                              //         ? Get.width * 0.105
                              //         : Get.width <= 420
                              //             ? Get.width * 0.115
                              //             : Get.width * 0.125,
                              child: Center(
                                child: SvgPicture.asset(
                                  rowCount.isEven
                                      ? "assets/icons/svg_icons/arrow_right.svg"
                                      : "assets/icons/svg_icons/arrow_left.svg",
                                  height: 24.0,
                                  width: 24.0,
                                  color: controller.chapterIndex.value >=
                                          (rowCount + index + 1)
                                      ? appColor
                                      : darkGrey,
                                ),
                              ),
                            )
                      : SizedBox(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget circularProgress(int index, BuildContext context) {
    return Container(
      height: 66,
      width: 88,
      child: SfRadialGauge(
        animationDuration: 500,
        enableLoadingAnimation: true,
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            axisLineStyle: AxisLineStyle(
              gradient: SweepGradient(
                colors: controller.allChapters[index]['correctAnswered'] ==
                            controller.allChapters[index]['totalQuestions'] &&
                        controller.chapterIndex.value >= index
                    ? [
                        Color.fromRGBO(30, 135, 255, 1.0),
                        Color.fromRGBO(107, 117, 255, 1.0)
                      ]
                    : [],
              ),
              color: controller.chapterIndex.value >= index
                  ? controller.allChapters[index]['correctAnswered'] ==
                          controller.allChapters[index]['totalQuestions']
                      ? Colors.transparent
                      : Color(0xffDAEBFF)
                  : Color(0xffEAEAEA),
              thickness: 10.5,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                width: 10.5,
                cornerStyle: circleProgressValue(index) <= 15.0
                    ? CornerStyle.bothFlat
                    : circleProgressValue(index) == 100.0
                        ? CornerStyle.bothFlat
                        : CornerStyle.bothCurve,
                sizeUnit: GaugeSizeUnit.logicalPixel,
                value: circleProgressValue(index),
                color: controller.chapterIndex.value >= index
                    ? controller.allChapters[index]['correctAnswered'] ==
                            controller.allChapters[index]['totalQuestions']
                        ? purpalColor.withOpacity(0.10)
                        : appColor
                    : appColor,
              ),
              if (circleProgressValue(index) <= 15.0)
                MarkerPointer(
                  value: circleProgressValue(index),
                  color: circleProgressValue(index) == 0.0 ||
                          circleProgressValue(index) == 100.0
                      ? Colors.transparent
                      : appColor,
                  offsetUnit: GaugeSizeUnit.factor,
                  markerType: MarkerType.circle,
                  markerHeight: 10.5,
                  markerWidth: 10.5,
                ),
              if (circleProgressValue(index) <= 15.0)
                MarkerPointer(
                  value: 0,
                  color: circleProgressValue(index) == 0.0 ||
                          circleProgressValue(index) == 100.0
                      ? Colors.transparent
                      : appColor,
                  offsetUnit: GaugeSizeUnit.factor,
                  markerType: MarkerType.circle,
                  markerHeight: 10.5,
                  markerWidth: 10.5,
                ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                positionFactor: 0.19,
                widget: levelCenterWidget(index, context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget chapterNameText(int index) {
    return Container(
      width: Get.width / 3 - 35,
      height: Get.width <= 415
          ? Get.width <= 405
              ? 55
              : 50
          : 45,
      padding: EdgeInsets.only(top: 5.0),
      alignment: Alignment.topCenter,
      child: TextAndStyle(
        title: controller.allChapters[index]['name'],
        fontSize: 11,
        color: tabBarText,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        textOverflow: TextOverflow.ellipsis,
        maxLine: 3,
      ),
    );
  }

  Widget levelCenterWidget(int index, BuildContext context) {
    return InkWell(
      onTap: () async {
        onChapterClick(index, context);
      },
      child: Container(
        height: 54,
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: controller.chapterIndex.value >= index
              ? controller.allChapters[index]['correctAnswered'] ==
                      controller.allChapters[index]['totalQuestions']
                  ? LinearGradient(
                      colors: [appColor, purpalColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      tileMode: TileMode.clamp)
                  : LinearGradient(
                      colors: [darkGrey, darkGrey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      tileMode: TileMode.clamp)
              : LinearGradient(
                  colors: [darkGrey, darkGrey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  tileMode: TileMode.clamp),
        ),
        child: Center(
          child: TextAndStyle(
            title: controller.allChapters[index]['id'].toString(),
            color: primaryWhite,
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  void onChapterClick(int index, BuildContext context) {
    _textScreenController.questions.clear();
    if ((index) == 0) {
      controller.chapterOnTap(chapterId: controller.allChapters[index]['id']);
    } else if (controller.chapterIndex.value >= index) {
      controller.chapterOnTap(chapterId: controller.allChapters[index]['id']);
    } else {
      if (controller.getStorage.read('isSubscribe') != true) {
        ShowModalsheet.oneButtomModalSheet(
          height: 380,
          barrierDismissible: true,
          title: currentLanguage['noti_lockedLessonTitle'],
          description: currentLanguage['noti_lockedLessonText'],
          okbtnTitle: currentLanguage['btn_upgradeFullVersion'],
          onOkPress: () {
            Get.back();
            tryPlus(context);
          },
          icon: SvgPicture.asset(
            'assets/images/subscription_boy.svg',
            height: 100,
          ),
        );
      }
    }
  }
}
