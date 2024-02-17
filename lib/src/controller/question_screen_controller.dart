import 'dart:async';
import 'dart:developer';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/main_home_controller.dart';
import 'package:drive/src/controller/statistics_screen_controller.dart';
import 'package:drive/src/controller/training_screen_controller.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/modules/Questions/option_decoration.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/exam/exam_result_screen.dart';
import 'package:drive/src/modules/google_ads/Interstitial_ads.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/buttons/elevated_button.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'home_controller.dart';

RxList offlineAnswered = [].obs;
RxList offlineIsFavorite = [].obs;

class QuestionScreenController extends GetxController {
  RxDouble progressValue = 0.0.obs;
  RxInt currentQuestionIndex = 0.obs;
  PageController pageController = PageController();
  GetStorage _getStorage = GetStorage();
  RxList questions = [].obs;
  RxList answers = [].obs;
  RxBool isFavorite = false.obs;
  NetworkRepository networkRepository = locator<NetworkRepository>();
  DatabaseHelper databaseHelper = DatabaseHelper();
  Map<String, String> correctAnswers = {};
  RxList correctLatters = [].obs;
  RxBool isCorrected = false.obs;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  Rx<TextEditingController> textEditingController =
      Rx<TextEditingController>(TextEditingController());
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  InterstitialHelper interstitialHelper = InterstitialHelper();
  HomeController homeController = Get.find();
  RxInt adsIndex = 0.obs;
  late Timer timer;
  RxInt timerStart = 0.obs;
  RxString currentChapter = ''.obs;
  RxBool isFromHome = true.obs;
  RxBool popUpOn = false.obs;
  RxInt pointsAchieved = 0.obs;
  RxInt questionsCorrect = 0.obs;
  Timer? popupTimer;
  RxInt popupConut = 2.obs;
  RxInt randomcount = 0.obs;
  RxInt questionCount = 0.obs;
  RxList rankListofUser = [].obs;
  RxBool isShowingAds = false.obs;

  @override
  void onInit() {
    if (questions.isNotEmpty) {
      isFavorite = questions[0]['isFavorite'];
    }
    offlineAnswered.value = _getStorage.read('pendingAnsweredQuestions') != null
        ? _getStorage.read('pendingAnsweredQuestions').toList()
        : [];

    popupTimer = Timer.periodic(
      Duration(hours: 1),
      (Timer timer) {
        popupConut.value = 2;
      },
    );
    super.onInit();
  }

  @override
  void dispose() {
    timer.cancel();
    popupTimer?.cancel();
    super.dispose();
  }

  void scrollTo(int index) => itemScrollController.scrollTo(
        index: index,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOutCubic,
      );

  void jumpTo(int index) => itemScrollController.jumpTo(
        index: index,
      );

  Future<void> backButton(RxDouble totalQuestions) async {
    select.clear();
    seletedMap.clear();
    nextQuestion.value = false;
    if (!isFromHome.value) {
      ShowModalsheet.twoButtomModalSheet(
        height: 230,
        title: currentLanguage['modal_confirmExitRandomTitle'],
        description: currentLanguage['modal_confirmExitRandomText'],
        onOkPress: () async {
          Get.back();
          if (pointsAchieved.value > 0 && isInternetOn.value) {
            await showpopUp();
          } else {
            Get.back();
          }
        },
        okbtnTitle: currentLanguage['global_yes'],
        cancelbtnTitle: currentLanguage['global_no'],
        onCancelPress: () {
          Get.back();
        },
      );
    } else {
      if (pointsAchieved.value > 0 && popupConut.value > 0) {
        await showpopUp();
      } else {
        Get.back();
      }
    }
  }

  showpopUp() async {
    Map? userlist = await networkRepository.getUsersRank(null);
    if (userlist != null) {
      RxInt currentRank = 0.obs;
      rankListofUser.value = userlist['data']['users'];
      rankListofUser.sort(
        (a, b) {
          return (b['points'].compareTo(a['points']));
        },
      );
      for (int i = 0; i < rankListofUser.length; i++) {
        if (int.parse(_getStorage.read('userId')) ==
            rankListofUser[i]['userId']) {
          currentRank.value = i + 1;
        }
      }
      if (currentRank.value < _getStorage.read('userPosition')) {
        String translation = currentLanguage['info_rankPlaceUp']
            .toString()
            .replaceAll('{0}', '${_getStorage.read('userPosition')}');
        String finalTranslation =
            translation.replaceAll('{1}', '${currentRank.value}');
        showBottomSheet(finalTranslation);
      } else {
        String translation = currentLanguage['info_rankPlace']
            .toString()
            .replaceAll('{0}', '${currentRank.value}');
        showBottomSheet(translation);
      }
      pointsAchieved.value = 0;
      _getStorage.write('userPosition', currentRank.value);
    } else {
      Get.back();
    }
  }

  showBottomSheet(String translations) {
    Get.bottomSheet(
      Container(
        height: 330,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 53,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 28, right: 28),
                margin: EdgeInsets.fromLTRB(0, 12, 0, 18),
                decoration: BoxDecoration(
                    color: blackColor, borderRadius: BorderRadius.circular(4)),
              ),
              Image.asset(
                "assets/gif/congrats.gif",
                height: 125.0,
                width: 125.0,
              ),
              SizedBox(
                height: 18,
              ),
              TextAndStyle(
                title: congratsMessage(translations),
                color: blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: SecondaryButton(
                        onPressed: () {
                          tabIndex.value = 1;
                          Get.back();
                          Get.back();
                          Get.find<MainHomeController>().onBottomIconClick(2);
                          Get.find<StatisticsScreenController>()
                              .topTabController!
                              .animateTo(1);
                        },
                        title: currentLanguage['btn_seeRanking'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      backgroundColor: whiteColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ).then((value) {
      popupConut--;
      Get.back();
    });
  }

  Future<void> doneOrSkipButton(isExamFromAPI, isFromSkip) async {
    select.clear();
    seletedMap.clear();
    nextQuestion.value = false;
    if ((currentQuestionIndex.value + 1) == questions.length) {
      bool showPopUp =
          await databaseHelper.correctQuestionOfChapter(currentChapter.value);
      if (isFromHome.value && !isFromSkip && showPopUp) {
        Get.back();
        bool correctQuestions = await databaseHelper.correctAllChapter();
        if (!correctQuestions) {
          ShowModalsheet.oneButtomModalSheet(
              height: 260,
              title: currentLanguage['noti_congratsChapterTitle'],
              description: currentLanguage['noti_congratsChapterMsg'],
              onOkPress: () {
                Get.back();
              },
              okbtnTitle: 'Ok');
        } else {
          ShowModalsheet.oneButtomModalSheet(
              height: 260,
              title: currentLanguage['noti_congratsAllChapterTitle'],
              description: currentLanguage['noti_congratsAllChapterMsg'],
              onOkPress: () {
                Get.back();
              },
              okbtnTitle: 'Ok');
        }
      } else if (isFromSkip) {
        pageController.nextPage(
            duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
      } else {
        if (!isFromSkip) {
          if (pointsAchieved.value > 0 && popupConut.value > 0) {
            await showpopUp();
          } else {
            Get.back();
          }
        }
      }
    } else {
      if (!isInternetOn.value) {
        if (isFromHome.value) {
          int index = currentQuestionIndex.value + 1;
          bool check = checkVideoOrPicture(index);
          while (!check) {
            index = index + 1;
            if (index >= questions.length) {
              currentQuestionIndex.value = 0;
              check = true;
              if (isFromHome.value) {
                await homeController.chapterOnTap(
                    chapterId: homeController.activeQuestionChapter.value,
                    isFromQuestions: true);
              } else {
                Get.back();
              }
            } else {
              check = checkVideoOrPicture(index);
            }
          }
        } else {
          tainingSkip();
        }
      } else {
        pageController.nextPage(
            duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
      }
    }
    isCorrected.value = false;
    if (isExamFromAPI == true) {
      scrollTo(currentQuestionIndex.value);
    }
  }

  void pageChange(num, simulateExam) {
    currentQuestionIndex.value = num;
    isFavorite.value =
        questions[currentQuestionIndex.value]['isFavorite'].value;
    if (!Get.find<HomeController>().isSubscribe.value) {
      if (!simulateExam) {
        if (adsIndex.value ==
            GlobalSingleton.globalSingleton.interstitialAdPage) {
          adsIndex.value = 0;
          if (isInternetOn.value) {
            interstitialHelper.createInterad();
          }
        } else {
          adsIndex++;
        }
      }
    }
  }

  bool checkVideoOrPicture(int index) {
    if (questions[index]['hasVideo'].value ||
        questions[index]['hasPicture'].value) {
      return false;
    } else {
      pageController.jumpToPage(index);
      return true;
    }
  }

  void favoriteOnTap(index, isExamFromAPI) async {
    isFavorite.value = isFavorite.value ? false : true;
    if (isExamFromAPI != true) {
      print(isFavorite.value);
      await databaseHelper.setFavorite(
          questions[index]['questionId'].toString(), isFavorite.value);
    }
    questions[index]['isFavorite'].value = isFavorite.value;
    if (!isInternetOn.value) {
      offlineIsFavorite.add({
        "questionId": questions[index]['questionId'].toString(),
        "isFavorite": isFavorite.value
      });
      _getStorage.write('pendingIsFavorite', offlineIsFavorite);
    } else {
      await networkRepository.setFavorite(null, {
        "questionId": questions[index]['questionId'].toString(),
        "isFavorite": isFavorite.value
      });
    }
  }

  void countinueOnTap(BuildContext context, int examId, bool onSubmit) async {
    await saveAnswer(context, true, examId, onSubmit);
  }

  submitOnTap(BuildContext context, int examId, bool questionCheck) async {
    if (seletedMap.values.toList().contains('1') ||
        textEditingController.value.text != "") {
      int isSkiped = questions
          .where((e) {
            return e['isSkip'] == true;
          })
          .toList()
          .length;
      if (isSkiped > 0) {
        ShowModalsheet.twoButtomModalSheet(
          height: 260,
          title: currentLanguage['exam_popup'],
          description: currentLanguage['exam_popupTitle'],
          okbtnTitle: currentLanguage['exam_popupBtn'],
          cancelbtnTitle: currentLanguage['btn_cancel'],
          onOkPress: () => onSubmit(context, examId, questionCheck, true),
          onCancelPress: () {
            Get.back();
          },
        );
      } else {
        onSubmit(context, examId, questionCheck, false);
      }
    } else {
      ShowModalsheet.twoButtomModalSheet(
        height: 260,
        title: currentLanguage['exam_popup'],
        description: currentLanguage['exam_popupTitle'],
        okbtnTitle: currentLanguage['exam_popupBtn'],
        cancelbtnTitle: currentLanguage['btn_cancel'],
        onOkPress: () => onSubmit(context, examId, questionCheck, true),
        onCancelPress: () {
          Get.back();
        },
      );
    }
  }

  Future<void> onSubmit(BuildContext context, int examId, bool questionCheck,
      bool fromDialog) async {
    answers.clear();
    if (questionCheck) {
      countinueOnTap(context, examId, true);
    }
    for (int i = 0; i < questions.length; i++) {
      answers.add({
        "questionId": questions[i]['questionId'].toString(),
        "isCorrect": questions[i]['isCorrect'].value,
        "givenAnswer": questions[i]['givenAnswer'].toString(),
        "examId": questions[i]['examId']
      });
    }
    Map response = await _networkRepository.finish(context, {
      "examId": examId,
      "examQuestionAnswers": answers,
    });
    if (response['statusCode'] == '200' || response['statusCode'] == 200) {
      for (int i = 0; i < questions.length; i++) {
        await databaseHelper.questionUpdate(
          questions[i]['questionId'].toString(),
          questions[i]['isCorrect'].value,
          '',
          questions[i]['chapterId'].toString(),
        );
      }
      currentQuestionIndex.value = 0;
      timer.cancel();
      if (fromDialog) {
        Get.back();
      }
      isExamStarted.value = false;
      Get.off(
        () => ExamResultScreen(
          examId: examId,
          isFromExam: true,
        ),
      );
    } else {
      print("API ERROR: ${response['message']}");
    }
  }

  void indexList(index, context) {
    saveAnswer(context, false, index, false);
    update();
  }

  saveAnswer(context, bool isContinue, int examIdOrIndex, bool onSubmit) async {
    RxString givenAnswer = "".obs;
    log(questions[currentQuestionIndex.value]['chapterId'].toString() +
        " :::: ");
    if (seletedMap.values.toList().contains('1') ||
        textEditingController.value.text != "") {
      if (questions[currentQuestionIndex.value]['differentAnswer'].value ==
          '') {
        correctAnswers.clear();
        for (int i = 0;
            i < questions[currentQuestionIndex.value]['answers'].value.length;
            i++) {
          correctAnswers[String.fromCharCode(65 + i)] =
              questions[currentQuestionIndex.value]['answers']
                  .value[i]
                  .values
                  .toList()[0]
                  .toString();
          givenAnswer.value =
              givenAnswer.value + seletedMap.values.toList()[i].toString();
        }
        correctLatters.value = correctAnswers.entries
            .where((element) => element.value.toString() == '1' ? true : false)
            .toList();
        if (correctAnswers.toString() == seletedMap.toString()) {
          isCorrected.value = true;
        } else {
          isCorrected.value = false;
        }
      } else {
        if (formKey.currentState!.validate()) {
          FocusScope.of(context).unfocus();
          isCorrected.value =
              (questions[currentQuestionIndex.value]['differentAnswer'].value ==
                  textEditingController.value.text);
          givenAnswer.value = textEditingController.value.text;
        }
      }
      log('isCorrect: ${isCorrected.value}: givenAnswer : ${givenAnswer.value}');
      questions[currentQuestionIndex.value]['isSkip'].value = false;
      questions[currentQuestionIndex.value]['isDone'].value = true;
      questions[currentQuestionIndex.value]['isCorrect'].value =
          isCorrected.value;
      questions[currentQuestionIndex.value]['givenAnswer'].value =
          givenAnswer.value;
    } else {
      questions[currentQuestionIndex.value]['isDone'].value = false;
      questions[currentQuestionIndex.value]['isSkip'].value = true;
      questions[currentQuestionIndex.value]['givenAnswer'].value =
          questions[currentQuestionIndex.value]['differentAnswer'].value == ''
              ? '000'
              : '';
    }
    if (isContinue) {
      if (onSubmit != true) {
        if ((currentQuestionIndex.value + 1) == questions.length) {
          await submitOnTap(context, examIdOrIndex, false);
        } else {
          pageController.nextPage(
              duration: Duration(
                milliseconds: 100,
              ),
              curve: Curves.bounceInOut);
        }
      }
    } else {
      pageController.jumpToPage(examIdOrIndex);
    }
    select.clear();
    seletedMap.clear();
    textEditingController.value.text = "";
    nextQuestion.value = false;
    isCorrected.value = false;
    scrollTo(currentQuestionIndex.value);
  }

  Future<void> countdownStart(
      context, isSimulateExam, examId, int? questionStartIndex) async {
    if (questions.length != 0) {
      isFavorite = questions[0]['isFavorite'];
    }
    if (questionStartIndex != null) {
      currentQuestionIndex.value = questionStartIndex;
    }
    pageController = PageController(initialPage: currentQuestionIndex.value);
    popUpOn.value = false;
    if (isSimulateExam == true) {
      Map getCountdownMinutes =
          await _networkRepository.getCountdownMinutes(context);
      if (getCountdownMinutes['statusCode'] == 200) {
        timerStart.value =
            Duration(minutes: getCountdownMinutes['data']).inSeconds;
      }
      timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) async {
          if (timerStart.value == 0) {
            timer.cancel();
            ShowModalsheet.oneButtomModalSheet(
                height: 260,
                title: currentLanguage['lbl_examFinished'],
                description: currentLanguage['lbl_examFinishedText'] ??
                    'Your exam time has been completed...',
                onOkPress: () => onSubmit(context, examId, true, true),
                okbtnTitle: currentLanguage['global_ok']);
          } else {
            if (isInternetOn.value) {
              timerStart--;
              if (popUpOn.value) {
                popUpOn.value = false;
                Get.back();
              }
            } else {
              if (!popUpOn.value) {
                popUpOn.value = true;
                ShowModalsheet.oneButtomModalSheet(
                    height: 230,
                    title: currentLanguage['noti_netErrorTitle'],
                    description: currentLanguage['noti_waitNetMsg'],
                    onOkPress: () {
                      select.clear();
                      seletedMap.clear();
                      nextQuestion.value = false;
                      currentQuestionIndex.value = 0;
                      timer.cancel();
                      Get.back();
                      Get.back();
                    },
                    okbtnTitle: currentLanguage['noti_waitNetBtn']);
              }
            }
          }
        },
      );
    }
  }

  String congratsMessage(String finalTranslation) {
    log(finalTranslation);
    String correctQuestions = currentLanguage['congrats_pointsAchieved']
        .replaceAll('{0}', '$questionsCorrect');
    String firstMessage = correctQuestions.replaceAll(
        '{1}', questionsCorrect.value > 1 ? 'n' : '');
    String mainMessage =
        firstMessage.replaceAll('{2}', '${pointsAchieved.value}');
    String finalMessage = mainMessage.replaceAll('{3}', '$finalTranslation');
    return finalMessage;
  }

  void tainingSkip() async {
    if (randomcount.toInt() == 0) {
      questions.removeWhere((element) {
        if (element['hasPicture'].value == true ||
            element['hasVideo'].value == true) {
          randomcount++;
          return true;
        } else {
          return false;
        }
      });
      if (randomcount.toInt() != 0) {
        RxList questionWithoutAssets =
            await databaseHelper.getQuestionsWithoutAssets();
        questionWithoutAssets.shuffle();
        Get.find<TrainingScreenController>().setQuestion(
            questionWithoutAssets.getRange(0, randomcount.value).toList(),
            isTrainSkip: true);
        update();
      }
    }
    pageController.nextPage(
        duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
  }

  Future<void> isShowReview() async {
    bool isReviewdApp = _getStorage.read('isReviewdApp') ?? false;
    if (isReviewdApp != true) {
      bool isShown = _getStorage.read('isShown') ?? false;
      if (!isShown) {
        await reviewPopUp();
        _getStorage.write('isShown', true);
      } else {
        await reviewPopUp();
        _getStorage.write('isShown', true);
      }
    }
  }

  Future<void> reviewPopUp() async {
    await InAppReview.instance.requestReview();
    _getStorage.write('isReviewdApp', true);
  }

  void previousButton() {
    select.clear();
    seletedMap.clear();
    nextQuestion.value = false;
    pageController.previousPage(
        duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
  }
}
