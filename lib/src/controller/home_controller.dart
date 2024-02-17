import 'dart:async';
import 'package:drive/main_home_screen.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/main_home_controller.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/models/chapter_model.dart';
import 'package:drive/src/models/questions_model.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/utils/network_dio/network_dio.dart';
import 'package:drive/src/utils/process_indicator.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:sqflite/sqflite.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/utils/locator.dart';
import '../binding/main_home_screen_binding.dart';
import '../singleton/global_singleton.dart';

class HomeController extends GetxController {
  RxInt listSize = 0.obs;
  RxInt chapterIndex = 0.obs;
  List<int> levelList = [];
  RxList allChapters = [].obs;
  GetStorage getStorage = GetStorage();
  DatabaseHelper databaseHelper = DatabaseHelper();
  ChapterModel chapterModel = ChapterModel();
  QuestionsModel questionsModel = QuestionsModel();
  RxList<String> activeChapter = <String>[].obs;
  RxList<String> doneChapters = <String>[].obs;
  RxInt points = 0.obs;
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  Timer? timer;
  Circle progressIndicator = Circle();
  RxString activeQuestionChapter = ''.obs;
  RxBool callConfigrationAPI = true.obs;
  RxBool updateAppPopUp = false.obs;
  RxInt timerTick = 0.obs;
  RxInt currentChapterIndex = 0.obs;
  RxBool isSubscribe = (GetStorage().read('isSubscribe') == true).obs;

  @override
  void onInit() {
    super.onInit();
    getUser(null);
    getConfigurations(null);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  getConfigurations(BuildContext? context) async {
    callConfigrationAPI.value = false;
    final response = await _networkRepository.getConfigurations(null);
    if (response != null && response['statusCode'] == 200) {
      String oldTranslationVersion = getStorage.read('translationVersion');
      String oldQuestionVersion = getStorage.read('questionVersion');
      List acceptedAppVersions = response['data']['appVersion'];
      String translationVersion = response['data']['translationVersion'];
      String questionVersion = response['data']['questionVersion'];
      GlobalSingleton.globalSingleton.adsSeconds =
          int.parse(response['data']['adBannerTimeoutSeconds']);
      GlobalSingleton.globalSingleton.interstitialAdPage =
          int.parse(response['data']['adAfterNoQuestions']);
      updateApp(acceptedAppVersions);
      updateTranslation(translationVersion, oldTranslationVersion);
      await updateQuestions(questionVersion, oldQuestionVersion, context);
    }
    callConfigrationAPI.value = true;
  }

  getUser(BuildContext? context) async {
    final response = await _networkRepository.getUserDetails(null);
    if (response != null) {
      if (response['statusCode'] == 200) {
        if (response['data']['expiresSubscription'] != null) {
          DateTime expiresSubscription =
              DateTime.parse(response['data']['expiresSubscription']).toUtc();
          DateTime now = DateTime.now().toUtc();
          Duration duration = now.difference(expiresSubscription);
          if (duration.isNegative) {
            isSubscribe.value = true;
            getStorage.write('isSubscribe', true);
          } else {
            isSubscribe.value = false;
            getStorage.write('isSubscribe', false);
          }
        } else {
          isSubscribe.value = false;
          getStorage.write('isSubscribe', false);
        }
      }
    }
  }

  getChapter({context, bool? isChecked}) async {
    if (getStorage.read('invitationToken') != null) {
      inviteFunction();
    }
    allChapters.value = [];
    levelList = [];
    doneChapters.value = [];
    bool isSaved = false;
    activeChapter.clear();
    List correctAnsweredQuestions =
        await databaseHelper.getCorrectAnsweredQuestions();
    int pointCount = 0;
    for (int i = 0; i < correctAnsweredQuestions.length; i++) {
      pointCount = (correctAnsweredQuestions[i]['points'] *
              correctAnsweredQuestions[i]['correct']) +
          pointCount;
    }
    points.value = pointCount;
    Future<Database> dbFuture = databaseHelper.initDb();
    isSubscribe.value = getStorage.read('isSubscribe') == true;
    dbFuture.then((database) {
      final noteListFuture = databaseHelper.getChapter();
      noteListFuture.then((index) {
        allChapters.value = index;
        for (int i = 0; i < allChapters.length; i++) {
          if (((i) % 3 == 0)) {
            levelList.add(i);
          }
        }
        for (int i = 0; i < allChapters.length; i++) {
          activeChapter.add(allChapters[i]['id'].toString());
          if (allChapters[i]['totalQuestions'] !=
              allChapters[i]['correctAnswered']) {
            chapterIndex.value = i;
            if (!isSaved) {
              currentChapterIndex.value = i;
              isSaved = true;
            }
            if (isSubscribe.value != true) {
              break;
            }
          } else {
            doneChapters.add(activeChapter[i]);
            if (allChapters.length == activeChapter.length) {
              currentChapterIndex.value = i;
              chapterIndex.value = allChapters.length;
            } else {
              currentChapterIndex.value = i;
              chapterIndex.value = i;
            }
          }
        }
        print('UPDATE');
        update();
      });
    });
    if (context != null) {
      timer = Timer.periodic(
        Duration(seconds: 60),
        (timer) {
          if (timerTick < timer.tick) {
            timerTick.value = timer.tick;
            final bool isLogging = getStorage.read('isLoggedIn') ?? false;
            if (isInternetOn.value &&
                callConfigrationAPI.value &&
                isLogging &&
                !NetworkDioHttp().isAPICalling.value &&
                !isExamStarted.value &&
                !updateAppPopUp.value) getConfigurations(context);
          }
        },
      );
    }
  }

  inviteFunction() async {
    Map readResponse = await _networkRepository.acceptJoinApp(
        {'userOrContactUid': getStorage.read('invitationToken')});
    if (readResponse['statusCode'] == 200) {
      getStorage.write('invitationToken', null);
      ShowModalsheet.oneButtomModalSheet(
          height: 230,
          title: currentLanguage['modal_welcomeTitle'],
          onOkPress: () {
            Get.back();
          },
          description: currentLanguage['modal_welcomeText'],
          okbtnTitle: currentLanguage['global_ok']);
    }
  }

  chapterOnTap({chapterId, isFromQuestions}) async {
    Get.find<QuestionScreenController>().questions.clear();
    Get.find<QuestionScreenController>().pointsAchieved.value = 0;
    Get.find<QuestionScreenController>().questionsCorrect.value = 0;
    Map<String, dynamic> setQuestions = {};
    if (isFromQuestions == true) {
      setQuestions['validQuetions'] =
          await databaseHelper.getQuestions(chapterId.toString());
    } else {
      final Map<String, List> questions =
          await databaseHelper.validQuestions(chapterId.toString());
      setQuestions['previousQuetions'] = questions['previousQuetions'];
      setQuestions['validQuetions'] = questions['questions'];
    }
    activeQuestionChapter.value = chapterId.toString();
    for (int t = 0; t < setQuestions.values.length; t++) {
      for (int i = 0; i < setQuestions.values.toList()[t].length; i++) {
        RxList listofAns = [].obs;
        RxString differentAnswer = ''.obs;
        if (setQuestions.values.toList()[t][i]['answer2'] != '') {
          for (int j = 0; j < 3; j++) {
            listofAns.add({
              setQuestions.values
                      .toList()[t][i]['answer${j + 1}']
                      .toString()
                      .obs:
                  setQuestions.values
                      .toList()[t][i]['solution'][j]
                      .toString()
                      .obs
            });
          }
          if (setQuestions.values.toList()[t][i]['answer3'] != '') {
            listofAns.shuffle();
          }
        } else {
          differentAnswer.value =
              setQuestions.values.toList()[t][i]['solution'];
          for (int j = 0; j < 3; j++) {
            if (setQuestions.values.toList()[t][i]['answer${j + 1}'] != '') {
              listofAns.add({
                setQuestions.values
                        .toList()[t][i]['answer${j + 1}']
                        .toString()
                        .obs:
                    setQuestions.values
                        .toList()[t][i]['solution']
                        .toString()
                        .obs
              });
            }
          }
        }
        Get.find<QuestionScreenController>().questions.add({
          "question":
              setQuestions.values.toList()[t][i]['title'].toString().obs,
          "questionId":
              setQuestions.values.toList()[t][i]['questionId'].toString().obs,
          "chapterId":
              setQuestions.values.toList()[t][i]['chapterId'].toString().obs,
          "subitle": setQuestions.values.toList()[t][i]['subitle'],
          "answers": listofAns,
          "points": setQuestions.values.toList()[t][i]['points'],
          "differentAnswer": differentAnswer,
          "nextQuestionId": setQuestions.values
              .toList()[t][((setQuestions.values.toList()[t].length - 1) == i)
                  ? 0
                  : (i + 1)]['questionId']
              .toString()
              .obs,
          "hasPicture":
              (setQuestions.values.toList()[t][i]['hasPicture'] == 1).obs,
          "hasVideo": (setQuestions.values.toList()[t][i]['hasVideo'] == 1).obs,
          "isFavorite": (setQuestions.values.toList()[t][i]['isFavorite'] ==
                      1 ||
                  setQuestions.values.toList()[t][i]['isFavorite'] == 'true')
              .obs,
        });
      }
    }
    List totalQuetions =
        await databaseHelper.getQuestions(chapterId.toString());
    Get.find<QuestionScreenController>().currentChapter.value =
        chapterId.toString();
    Get.find<QuestionScreenController>().isFromHome.value = true;
    if (isFromQuestions == true) {
      Get.back();
      Get.to(() => QuestionScreen(
            totalQuestions: totalQuetions.length,
          ))?.then((value) async {
        Get.find<QuestionScreenController>().currentQuestionIndex = 0.obs;
        getChapter();
      });
    } else {
      Get.to(() => QuestionScreen(
            totalQuestions: totalQuetions.length,
            questionStartIndex: setQuestions['previousQuetions'].length,
          ))?.then((value) async {
        Get.find<QuestionScreenController>().currentQuestionIndex = 0.obs;
        getChapter();
      });
    }
  }

  void updateTranslation(
      String translationVersion, String oldTranslationVersion) async {
    if (translationVersion != oldTranslationVersion) {
      Map translation = {};
      Map enTranslationsData =
          await _networkRepository.getTranslations(null, 'en');
      Map deTranslationsData =
          await _networkRepository.getTranslations(null, 'de');
      if (deTranslationsData.isNotEmpty && enTranslationsData.isNotEmpty) {
        translation['en'] = enTranslationsData;
        translation['de'] = deTranslationsData;
        getStorage.write('translation', translation);
        getStorage.write('translationVersion', translationVersion);
        Get.find<LanguageController>()
            .changeCurrentLanguage(getStorage.read('language'));
      }
    }
  }

  void updateApp(List acceptedAppVersions) {
    if (updateAppPopUp.value) {
      Get.back();
      updateAppPopUp.value = false;
    }
    if (!acceptedAppVersions.contains(_globalSingleton.appVersion)) {
      updateAppPopUp.value = true;
      ShowModalsheet.oneButtomModalSheet(
          height: 230,
          title: currentLanguage['modal_updateAppTitle'],
          description: currentLanguage['modal_updateAppText'],
          onOkPress: () {
            StoreRedirect.redirect(
              androidAppId: "com.Fahrschulhero",
              iOSAppId: "1599075528",
            );
          },
          okbtnTitle: 'Update');
    }
  }

  Future<void> updateQuestions(
      String questionVersion, String oldQuestionVersion, context) async {
    if (questionVersion != oldQuestionVersion) {
      final response =
          await _networkRepository.getAllQuestions(Get.overlayContext);
      if (response != null) {
        if (response['statusCode'] == 200 || response['statusCode'] == '200') {
          progressIndicator.show(Get.overlayContext);
          await databaseHelper.deleteTable();
          await databaseHelper.onCreate();
          await databaseHelper.insertChapter(response);
          progressIndicator.hide(Get.overlayContext);
          getStorage.write('questionVersion', questionVersion);
          pageIndex.value = 0;
          Get.offAll(() => MainHomeScreen(), binding: MainHomeBinding());
        } else {
          if (progressIndicator.isShow)
            progressIndicator.hide(Get.overlayContext);
        }
      }
    }
  }
}
