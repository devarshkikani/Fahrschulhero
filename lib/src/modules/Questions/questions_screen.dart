import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/modules/Questions/question_page/question_page_builder.dart';
import 'package:drive/src/modules/google_ads/banner_ads.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

RxBool isInternetOn = false.obs;
RxBool isExamStarted = false.obs;

// ignore: must_be_immutable
class QuestionScreen extends GetView<QuestionScreenController> {
  QuestionScreen(
      {Key? key,
      required this.totalQuestions,
      this.simulateExam,
      this.examId,
      this.questionStartIndex})
      : super(key: key);

  int totalQuestions;
  bool? simulateExam;
  int? examId;
  int? questionStartIndex;
  String timer(int startSeconds) {
    int minutes = startSeconds ~/ 60;
    int seconds = (startSeconds % 60);
    String timeToShow = minutes.toString().padLeft(2, "0") +
        ":" +
        seconds.toString().padLeft(2, "0");

    return timeToShow;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (simulateExam != true) {
          Get.back();
        }
        return simulateExam == true ? false : true;
      },
      child: GetBuilder<QuestionScreenController>(
        initState: (state) async => await controller.countdownStart(
            context, simulateExam, examId, questionStartIndex),
        builder: (_) => Scaffold(
          backgroundColor: whiteColor,
          body: SafeArea(
            child: SizedBox(
              height: Get.height,
              child: Column(
                children: [
                  Obx(() {
                    return isInternetOn.value
                        ? const GoogleAds()
                        : const SizedBox();
                  }),
                  simulateExam == true
                      ? examScreenAppBar()
                      : withoutExamScreen(),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (simulateExam != true)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                color: Colors.transparent,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 22),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appColor.withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 13,
                                        color: appColor,
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 56,
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 22),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: appColor,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 13,
                                        color: whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: controller.pageController,
                                  onPageChanged: (int num) {
                                    controller.pageChange(
                                        num, simulateExam ?? false);
                                  },
                                  itemCount: controller.questions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return QuestionPageBuilder(
                                        question: controller.questions[index]
                                            ['question'],
                                        answers: controller.questions[index]
                                            ['answers'],
                                        differentAnswer:
                                            controller.questions[index]
                                                ['differentAnswer'],
                                        simulateExam: simulateExam ?? false,
                                        questionId: controller.questions[index]
                                            ['questionId'],
                                        chapterId: controller.questions[index]
                                            ['chapterId'],
                                        nextQuestionId: controller
                                            .questions[index]['nextQuestionId'],
                                        hasVideo: controller.questions[index]
                                            ['hasVideo'],
                                        hasPicture: controller.questions[index]
                                            ['hasPicture'],
                                        givenAnswer: controller.questions[index]
                                                    ['givenAnswer'] !=
                                                null
                                            ? controller
                                                .questions[index]['givenAnswer']
                                                .value
                                            : '000',
                                        watchCounter: controller
                                            .questions[index]['watchCounter'],
                                        points: controller.questions[index]
                                            ['points'],
                                        questionScreenController: controller,
                                        subitle: controller.questions[index]
                                            ['subitle']);
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: simulateExam == true
              ? SafeArea(
                  child: SizedBox(
                    height: 160,
                    child: Column(
                      children: [
                        Container(
                          color: lightGreenColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buttons(
                                  color: redColor,
                                  onTap: () {
                                    controller.submitOnTap(
                                        context, examId!, true);
                                  },
                                  title: currentLanguage['exam_submission']),
                              const SizedBox(
                                width: 12,
                              ),
                              Obx(
                                () => !controller.isFavorite.value
                                    ? buttons(
                                        color: yellowColor,
                                        onTap: () {
                                          if (!controller.isFavorite.value) {
                                            controller.favoriteOnTap(
                                                controller
                                                    .currentQuestionIndex.value,
                                                simulateExam);
                                          }
                                        },
                                        title: currentLanguage['exam_mark'])
                                    : const SizedBox(),
                              ),
                              Obx(
                                () => SizedBox(
                                  width: !controller.isFavorite.value ? 12 : 0,
                                ),
                              ),
                              buttons(
                                  color: appColor,
                                  onTap: () {
                                    controller.countinueOnTap(
                                        context, examId!, false);
                                  },
                                  title:
                                      (controller.currentQuestionIndex.value +
                                                  1) ==
                                              controller.questions.length
                                          ? currentLanguage['global_done']
                                          : currentLanguage['exam_continue']),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: greenColor,
                            child: ScrollablePositionedList.builder(
                                itemCount: controller.questions.length,
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 12),
                                scrollDirection: Axis.horizontal,
                                itemScrollController:
                                    controller.itemScrollController,
                                itemPositionsListener:
                                    controller.itemPositionsListener,
                                itemBuilder: (BuildContext context, int index) {
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            controller.indexList(
                                                index, context);
                                          },
                                          child: Obx(
                                            () => Container(
                                              margin: const EdgeInsets.all(5),
                                              width: 45,
                                              decoration: BoxDecoration(
                                                color: controller
                                                        .questions[index]
                                                            ['isDone']
                                                        .value
                                                    ? greenColor
                                                    : whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    width: index ==
                                                            controller
                                                                .currentQuestionIndex
                                                                .value
                                                        ? 2
                                                        : 1,
                                                    color: controller
                                                            .questions[index]
                                                                ['isDone']
                                                            .value
                                                        ? blackColor
                                                        : index ==
                                                                controller
                                                                    .currentQuestionIndex
                                                                    .value
                                                            ? blackColor
                                                            : Colors
                                                                .transparent),
                                              ),
                                              alignment: Alignment.center,
                                              child: TextAndStyle(
                                                title: "${index + 1}",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: controller
                                                        .questions[index]
                                                            ['isDone']
                                                        .value
                                                    ? whiteColor
                                                    : blackColor,
                                              ),
                                            ),
                                          )),
                                      Obx(() => controller
                                              .questions[index]['isFavorite']
                                              .value
                                          ? Positioned(
                                              right: 0.0,
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                child: SvgPicture.asset(
                                                    "assets/icons/svg_icons/triangle.svg"),
                                              ),
                                            )
                                          : const SizedBox()),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  Widget examScreenAppBar() {
    return AppBar(
      title: TextAndStyle(
        title: currentLanguage['exam_title'],
        color: whiteColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      elevation: 0.0,
      backgroundColor: greenColor,
      leading: const SizedBox(),
      leadingWidth: 0.0,
      actions: [
        Obx(
          () => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: TextAndStyle(
                title: timer(controller.timerStart.value),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget withoutExamScreen() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Container(
              height: 28,
              width: 80,
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () => Text(
                    '${controller.questions[controller.currentQuestionIndex.value]['points']} ${currentLanguage['short_points']}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  return FlutterSlider(
                    values: [
                      ((totalQuestions - controller.questions.length) +
                              controller.currentQuestionIndex.value)
                          .toDouble()
                    ],
                    max: totalQuestions.toDouble() > 0
                        ? totalQuestions.toDouble()
                        : 100.0,
                    min: 0,
                    visibleTouchArea: false,
                    disabled: true,
                    handlerHeight: 10,
                    tooltip: FlutterSliderTooltip(
                      direction: FlutterSliderTooltipDirection.right,
                      disabled: true,
                    ),
                    trackBar: FlutterSliderTrackBar(
                      activeTrackBarHeight: 8,
                      inactiveTrackBarHeight: 8,
                      activeDisabledTrackBarColor: appColor,
                      activeTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      inactiveTrackBar: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onDragging: (handlerIndex, lowerValue, upperValue) {},
                    handler: FlutterSliderHandler(
                        decoration: const BoxDecoration(),
                        child: const SizedBox()),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  controller.backButton(totalQuestions.toDouble().obs);
                },
                child: Row(
                  children: [
                    const SizedBox(
                      width: 47,
                    ),
                    Container(
                      height: 28,
                      width: 28,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: appColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(
              () => TextAndStyle(
                title:
                    "${currentLanguage['question_question']} ${(totalQuestions - controller.questions.length) + controller.currentQuestionIndex.value + 1}/$totalQuestions",
                letterSpacing: 1.5,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: appColor,
              ),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                controller.favoriteOnTap(
                    controller.currentQuestionIndex.value, simulateExam);
              },
              child: Obx(
                () => controller.isFavorite.value
                    ? const Icon(
                        Icons.star_rate_rounded,
                        color: Colors.amber,
                      )
                    : const Icon(
                        Icons.star_border_rounded,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buttons({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          // margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: TextAndStyle(
            title: title,
            color: whiteColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: "rubik",
          ),
        ),
      ),
    );
  }
}
