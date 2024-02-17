import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/training_screen_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/exam/exam_result_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class TrainingScreen extends GetView<TrainingScreenController> {
  @override
  Widget build(BuildContext context) {
    controller.getChapter();
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        centerTitle: true,
        elevation: 0.0,
        title: Obx(() => TextAndStyle(
              title: currentLanguage['menu_training'],
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => TextAndStyle(
                    title: currentLanguage['train_practiceMode'],
                    color: blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
              SizedBox(
                height: 14,
              ),
              practiceMode(context),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                child: Obx(() => TextAndStyle(
                      title: currentLanguage['train_examMode'],
                      color: blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ),
              exam(context: context),
            ],
          ),
        ),
      ),
    );
  }

  Widget practiceMode(context) {
    return Column(
      children: [
        Obx(
          () => questionsDecoration(
            color: appColor,
            icon: 'assets/icons/svg_icons/randomQuestions.svg',
            title: currentLanguage['train_randomQuestions'],
            count: '${controller.randomQuestions.length}',
            onTap: () {
              if (controller.randomQuestions.length > 0) {
                randomQuizStart(
                  context: context,
                );
              } else {
                showSnackBar(
                  colorText: appColor,
                  message: "your not answerd any questions.",
                  title: currentLanguage['modal_oopsTitle'],
                );
              }
            },
          ),
        ),
        Obx(
          () => questionsDecoration(
            color: appColor,
            icon: 'assets/icons/svg_icons/savedQuestions.svg',
            title: currentLanguage['train_savedQuestions'],
            count: '${controller.savedQuestions.length}',
            onTap: () {
              if (controller.savedQuestions.length > 0) {
                controller.setQuestion(controller.savedQuestions);
              } else {
                showSnackBar(
                  title: currentLanguage['modal_oopsTitle'],
                  message: currentLanguage['modal_noSavedQuestions'],
                );
              }
            },
          ),
        ),
        Obx(
          () => questionsDecoration(
            color: redColor,
            icon: 'assets/icons/svg_icons/mistakes.svg',
            title: currentLanguage['train_mistakes'],
            count: '${controller.mistakes.length}',
            onTap: () {
              if (controller.mistakes.length > 0) {
                controller.setQuestion(controller.mistakes);
              } else {
                showSnackBar(
                  title: currentLanguage['modal_oopsTitle'],
                  message: currentLanguage['modal_noErrorQuestions'],
                  colorText: whiteColor,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget exam({required BuildContext context}) {
    return Obx(() => Column(
          children: [
            examDecoration(
              color: whiteColor,
              context: context,
              icon: 'assets/icons/svg_icons/SimulateIcon.svg',
              title: currentLanguage['train_simulateTitle'],
              backgroundColor: greenColor,
              borderColor: Colors.transparent,
              count: currentLanguage['train_simulateSubtitle'],
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
                  controller.simulateTestStart(context);
                }
              },
            ),
            examDecoration(
              color: greenColor,
              icon: 'assets/icons/svg_icons/latestExamIcon.svg',
              title: currentLanguage['train_latestTitle'],
              backgroundColor: whiteColor,
              borderColor: greenColor,
              context: context,
              count: currentLanguage['train_latestSubtitle'],
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
                  Get.to(
                    () => ExamResultScreen(
                      examId: 0,
                      isFromExam: false,
                    ),
                  );
                }
              },
            ),
          ],
        ));
  }

  Widget questionsDecoration({
    required Color color,
    required String title,
    required String count,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.10),
              blurRadius: 40,
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: color,
              ),
              child: SvgPicture.asset(icon),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextAndStyle(
                  title: title,
                  fontSize: 12,
                  color: textGrey,
                ),
                TextAndStyle(
                  title: count,
                  fontSize: 14,
                  color: tabBarText,
                ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              size: 28,
              color: arrowGreyColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget examDecoration({
    required Color color,
    required Color borderColor,
    required BuildContext context,
    required Color backgroundColor,
    required String title,
    required String count,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.10),
              blurRadius: 40,
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: color,
              ),
              child: SvgPicture.asset(icon),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextAndStyle(
                    title: title,
                    fontSize: 14,
                    color: borderColor == color ? textGrey : whiteColor,
                  ),
                  TextAndStyle(
                    title: count,
                    fontSize: 11,
                    color: borderColor == color ? tabBarText : whiteColor,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              size: 28,
              color: borderColor == color ? arrowGreyColor : whiteColor,
            ),
          ],
        ),
      ),
    );
  }

  void randomQuizStart({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.80,
          child: Container(
            color: whiteColor,
            height: Get.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 53,
                    padding: EdgeInsets.only(left: 28, right: 28),
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 36),
                    decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28, right: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextAndStyle(
                        title: currentLanguage['train_randomQuestions'],
                        fontSize: 18,
                        color: blackColor,
                      ),
                      TextAndStyle(
                        title: currentLanguage['random_chapterTitle'],
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: tabBarText,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    color: whiteColor,
                    child: ListView.builder(
                      itemCount: controller.moduleList.length,
                      shrinkWrap: false,
                      itemBuilder: (BuildContext context, int index) {
                        return randomChapter(index);
                      },
                    ),
                  ),
                ),
                button(
                    onTap: () async {
                      if (controller.selectedChaptersList.length != 0 ||
                          controller.allChapterSelected.value) {
                        Get.back();
                        controller.onDropDownChange();
                        randomQuizQuestionSelect(context: context);
                      }
                    },
                    title: currentLanguage['btn_next']),
              ],
            ),
          ),
        );
      },
    );
  }

  void randomQuizQuestionSelect({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.80,
          child: Container(
            color: whiteColor,
            height: Get.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 53,
                    padding: EdgeInsets.only(left: 28, right: 28),
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 36),
                    decoration: BoxDecoration(
                        color: blackColor,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28, right: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextAndStyle(
                        title: currentLanguage['train_randomQuestions'],
                        fontSize: 18,
                        color: blackColor,
                      ),
                      TextAndStyle(
                        title: currentLanguage['random_noTitle'],
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: tabBarText,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    color: whiteColor,
                    child: ListView.builder(
                      itemCount: controller.questionsList.length,
                      shrinkWrap: false,
                      itemBuilder: (BuildContext context, int index) {
                        return randomQuestionsListTile(index);
                      },
                    ),
                  ),
                ),
                button(
                    onTap: () async {
                      controller.randomSelectedData.shuffle();
                      Get.back();
                      List questionsList = controller.randomSelectedData
                          .sublist(0, int.parse(controller.questions.value));
                      RxInt removeCount = 0.obs;
                      print(questionsList.length);
                      if (!isInternetOn.value) {
                        questionsList.removeWhere((element) {
                          if (element['hasVideo'] == 1 ||
                              element['hasPicture'] == 1) {
                            removeCount++;
                            return true;
                          } else {
                            return false;
                          }
                        });
                        if (removeCount.value != 0) {
                          RxList questionWithoutAssets = await controller
                              .databaseHelper
                              .getQuestionsWithoutAssets();
                          questionWithoutAssets.shuffle();
                          questionsList.addAll(questionWithoutAssets
                              .getRange(0, removeCount.value)
                              .toList());
                        }
                        controller.setQuestion(questionsList);
                      } else {
                        controller.setQuestion(questionsList);
                      }
                      controller.randomSelectedData.value = [];
                      controller.selectedChaptersList.value = [];
                      controller.questions.value = '10';
                    },
                    title: currentLanguage['modal_startTraining']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget randomQuestionsListTile(int index) {
    return GestureDetector(
      onTap: () {
        controller.questions.value = controller.questionsList[index];
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(
          left: 28,
          right: 28,
          bottom: 10,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 40,
              color: tabBarText.withOpacity(0.06),
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.questionsList[index]}',
              style: TextStyle(
                color: tabBarText,
                fontSize: 14.0,
              ),
            ),
            Obx(
              () => Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: controller.questions.value ==
                          controller.questionsList[index]
                      ? appColor
                      : checkBoxColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: controller.questions.value ==
                        controller.questionsList[index]
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: whiteColor,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget randomChapter(int index) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          controller.allChapterSelected.value =
              !controller.allChapterSelected.value;
        } else {
          controller.allChapterSelected.value = false;
          if (controller.selectedChaptersList
              .contains(controller.moduleList[index].split(' ').first)) {
            controller.selectedChaptersList
                .remove(controller.moduleList[index].split(' ').first);
          } else {
            controller.selectedChaptersList
                .add(controller.moduleList[index].split(' ').first);
          }
        }
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(
          left: 28,
          right: 28,
          bottom: 10,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 40,
              color: tabBarText.withOpacity(0.06),
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.moduleList[index].split(' ').first}',
              style: TextStyle(
                color: tabBarText,
                fontSize: 14.0,
              ),
            ),
            if (index != 0)
              Expanded(
                child: Text(
                  ' ${controller.moduleList[index].split(' ')[1]}',
                  style: TextStyle(
                    color: tabBarText,
                    fontSize: 14.0,
                  ),
                ),
              ),
            Obx(
              () => Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: controller.allChapterSelected.value ||
                          controller.selectedChaptersList.contains(
                              controller.moduleList[index].split(' ').first)
                      ? appColor
                      : checkBoxColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: controller.allChapterSelected.value ||
                        controller.selectedChaptersList.contains(
                            controller.moduleList[index].split(' ').first)
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: whiteColor,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget button({required String title, required VoidCallback onTap}) {
    return Container(
      height: 100,
      width: Get.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: new LinearGradient(
          colors: [primaryWhite.withOpacity(0.0), primaryWhite],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: InkWell(
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: appColor,
          ),
          child: TextAndStyle(
              title: title,
              fontFamily: "Rubik",
              letterSpacing: 0.2,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: primaryWhite),
        ),
      ),
    );
  }

  Widget listItemDecoration({
    required Map title,
  }) {
    return GestureDetector(
        onTap: () {
          controller.selectedIndex.value = title.keys.toList()[0].toString();
        },
        child: Obx(
          () => Container(
            padding: EdgeInsets.all(18),
            margin: EdgeInsets.fromLTRB(0, 7, 0, 8),
            decoration: BoxDecoration(
              color: title.keys.toList()[0].toString() !=
                      controller.selectedIndex.value
                  ? whiteColor
                  : appColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.06),
                  blurRadius: 40,
                  offset: Offset(0, 13),
                ),
              ],
            ),
            child: Row(
              children: [
                TextAndStyle(
                  title: title.keys.toList()[0].toString(),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: title.keys.toList()[0].toString() ==
                          controller.selectedIndex.value
                      ? whiteColor
                      : tabBarText,
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: TextAndStyle(
                    title: title.values.toList()[0].toString(),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: title.keys.toList()[0].toString() ==
                            controller.selectedIndex.value
                        ? whiteColor
                        : tabBarText,
                    maxLine: 2,
                  ),
                ),
                title.keys.toList()[0].toString() ==
                        controller.selectedIndex.value
                    ? Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: appColor,
                        ),
                      )
                    : Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: checkBoxColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
