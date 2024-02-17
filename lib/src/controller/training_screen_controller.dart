import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/subscription/in_app_purchase.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite/sqflite.dart';

import 'question_screen_controller.dart';

class TrainingScreenController extends GetxController {
  RxString selectedIndex = '10'.obs;
  RxString module = ''.obs;
  List<String> moduleList = [];
  RxString questions = '10'.obs;
  RxList<String> questionsList = <String>['10'].obs;
  RxList randomSelectedData = [].obs;
  RxList chapterList = [].obs;
  RxList mistakes = [].obs;
  RxList savedQuestions = [].obs;
  RxList randomQuestions = [].obs;
  DatabaseHelper databaseHelper = DatabaseHelper();
  NetworkRepository networkRepository = locator<NetworkRepository>();
  RxBool isSubscribe = (GetStorage().read('isSubscribe') == true).obs;
  RxBool allChapterSelected = false.obs;
  RxList<String> selectedChaptersList = <String>[].obs;

  practiceData() async {
    savedQuestions.value = [];
    mistakes.value = [];
    moduleList = [];
    randomQuestions.value = [];
    module.value = currentLanguage['modal_all'];
    List allChapters = Get.find<HomeController>().allChapters;
    moduleList.add(currentLanguage['modal_all']);
    savedQuestions.addAll(await databaseHelper.savedQuestions());
    if (isSubscribe.value) {
      randomQuestions.addAll(await databaseHelper.getAllQuestions());
      allChapters.forEach((element) {
        moduleList.add("${element['id']} ${element['name']}");
      });
    }
    for (int i = 0; i < Get.find<HomeController>().activeChapter.length; i++) {
      mistakes.addAll(await databaseHelper
          .mistakes(Get.find<HomeController>().activeChapter[i].toString()));
      if (!isSubscribe.value) {
        randomQuestions.addAll(await databaseHelper.getQuestions(
            Get.find<HomeController>().activeChapter[i].toString()));
        moduleList.add(
            "${Get.find<HomeController>().allChapters[i]['id']} ${Get.find<HomeController>().allChapters[i]['name']}");
      }
    }
    questionsList.value = [];
    final setlength = (randomQuestions.length / 10).floor();
    for (int i = 0; i < setlength; i++) {
      questionsList.add('${i + 1}0');
    }
    if (randomQuestions.length < 10) {
      questions.value = randomQuestions.length.toString();
    }
    randomSelectedData.value = module.value == currentLanguage['modal_all']
        ? randomQuestions
        : randomQuestions.where((e) {
            return e['chapterId'].toString() == module.value;
          }).toList();
  }

  onDropDownChange() {
    if (allChapterSelected.value) {
      randomSelectedData.value = randomQuestions;
    } else {
      randomSelectedData.value = randomQuestions.where((e) {
        return selectedChaptersList.contains(e['chapterId'].toString());
      }).toList();
    }
    questionsList.value = [];
    final setlength = (randomSelectedData.length / 10).floor();
    for (int i = 0; i < setlength; i++) {
      questionsList.add('${i + 1}0');
    }
    if (randomSelectedData.length <= 10) {
      questions.value = randomSelectedData.length.toString();
    } else {
      questions.value = '10';
    }
  }

  getChapter() async {
    Future<Database> dbFuture = databaseHelper.initDb();
    dbFuture.then((database) {
      final noteListFuture = databaseHelper.getChapter();
      noteListFuture.then((index) {
        chapterList.value = [];
        for (int i = 0; i < index.length; i++) {
          chapterList.add({'${index[i]['id']}': '${index[i]['name']}'});
        }
        update();
      });
    });
    await practiceData();
  }

  simulateTestStart(context) async {
    Map canDoExam = await networkRepository.canDoExam(context);
    if (canDoExam['statusCode'] == 200 && canDoExam['data'] == true) {
      Map examData = await networkRepository.examStart(context);
      if (examData['statusCode'] == 200 || examData['statusCode'] == '200') {
        Get.find<QuestionScreenController>().questions.clear();
        Get.find<QuestionScreenController>().pointsAchieved.value = 0;
        Get.find<QuestionScreenController>().questionsCorrect.value = 0;
        for (int i = 0; i < examData['data'].length; i++) {
          RxList listofAns = [].obs;
          RxString differentAnswer = ''.obs;
          if (examData['data'][i]['question']['answer2'] != null) {
            for (int j = 0; j < 3; j++) {
              listofAns.add({
                examData['data'][i]['question']['answer${j + 1}']
                    .toString()
                    .obs: examData['data'][i]['question']['solution']
                        [j]
                    .toString()
                    .obs
              });
            }
          } else {
            differentAnswer.value = examData['data'][i]['question']['solution'];
            for (int j = 0; j < 3; j++) {
              if (examData['data'][i]['question']['answer${j + 1}'] != null) {
                listofAns.add({
                  examData['data'][i]['question']['answer${j + 1}']
                          .toString()
                          .obs:
                      examData['data'][i]['question']['solution'].toString().obs
                });
              }
            }
          }
          Get.find<QuestionScreenController>().questions.add({
            "question": examData['data'][i]['question']['title'].toString().obs,
            "questionId":
                examData['data'][i]['question']['questionId'].toString().obs,
            "chapterId":
                examData['data'][i]['question']['chapterId'].toString().obs,
            "answers": listofAns,
            "differentAnswer": differentAnswer,
            "nextQuestionId": examData['data']
                        [((examData['data'].length - 1) == i) ? 0 : (i + 1)]
                    ['question']['questionId']
                .toString()
                .obs,
            "hasPicture":
                (examData['data'][i]['question']['hasPicture'] == true).obs,
            "points": examData['data'][i]['question']['points'],
            "hasVideo":
                (examData['data'][i]['question']['hasVideo'] == true).obs,
            "isFavorite":
                (examData['data'][i]['question']['isFavorite'] == true).obs,
            "isDone": false.obs,
            "examId": examData['data'][i]['examId'],
            "givenAnswer": examData['data'][i]['question']['answer2'] != null
                ? "000".obs
                : ''.obs,
            "subitle": examData['data'][i]['question']['subitle'] ?? '',
            "isCorrect": false.obs,
            "isSkip": false.obs,
            "watchCounter": 3.obs,
          });
          Get.find<QuestionScreenController>().isFromHome.value = false;
          Get.find<QuestionScreenController>().currentQuestionIndex.value = 0;
          isExamStarted.value = true;
          Get.to(() => QuestionScreen(
                totalQuestions: examData['data'].length,
                simulateExam: true,
                examId: examData['data'][i]['examId'],
              ))?.then((value) {
            Future.delayed(Duration(milliseconds: 200), () {
              Get.find<QuestionScreenController>().currentQuestionIndex.value =
                  0;
            });
          });
        }
      }
    } else {
      ShowModalsheet.twoButtomModalSheet(
        height: 310,
        title: currentLanguage['exam_lockedTitle'],
        description: currentLanguage['exam_lockedMessage'],
        okbtnTitle: currentLanguage['exam_lockedBtnBuy'],
        cancelbtnTitle: currentLanguage['exam_lockedBtnOk'],
        onOkPress: () {
          Get.off(() => SubscriptionScreen());
        },
        onCancelPress: () {
          Get.back();
        },
      );
    }
  }

  setQuestion(data, {bool? isTrainSkip}) {
    if (isTrainSkip != true) {
      Get.find<QuestionScreenController>().questions.clear();
      Get.find<QuestionScreenController>().pointsAchieved.value = 0;
      Get.find<QuestionScreenController>().questionsCorrect.value = 0;
    }
    for (int i = 0; i < data.length; i++) {
      RxList listofAns = [].obs;
      RxString differentAnswer = ''.obs;
      if (data[i]['answer2'] != '') {
        for (int j = 0; j < 3; j++) {
          listofAns.add({
            data[i]['answer${j + 1}'].toString().obs:
                data[i]['solution'][j].toString().obs
          });
        }
        if (data[i]['answer3'] != '') {
          listofAns.shuffle();
        }
      } else {
        differentAnswer.value = data[i]['solution'];
        for (int j = 0; j < 3; j++) {
          if (data[i]['answer${j + 1}'] != '') {
            listofAns.add({
              data[i]['answer${j + 1}'].toString().obs:
                  data[i]['solution'].toString().obs
            });
          }
        }
      }
      Get.find<QuestionScreenController>().questions.add({
        "question": data[i]['title'].toString().obs,
        "questionId": data[i]['questionId'].toString().obs,
        "chapterId": data[i]['chapterId'].toString().obs,
        "subitle": data[i]['subitle'],
        "answers": listofAns,
        "differentAnswer": differentAnswer,
        "points": data[i]['points'],
        "nextQuestionId": data[((data.length - 1) == i) ? 0 : (i + 1)]
                ['questionId']
            .toString()
            .obs,
        "hasPicture": (data[i]['hasPicture'] == 1).obs,
        "hasVideo": (data[i]['hasVideo'] == 1).obs,
        "isFavorite":
            (data[i]['isFavorite'] == 1 || data[i]['isFavorite'] == 'true').obs,
      });
    }
    if (isTrainSkip != true) {
      Get.find<QuestionScreenController>().isFromHome.value = false;
      Get.find<QuestionScreenController>().randomcount.value = 0;
      Get.find<QuestionScreenController>().currentQuestionIndex.value = 0;
      Get.to(() => QuestionScreen(
            totalQuestions: data.length,
          ))?.then((value) async {
        Future.delayed(Duration(milliseconds: 200), () {
          Get.find<QuestionScreenController>().currentQuestionIndex.value = 0;
        });
        await practiceData();
      });
    }
  }
}
