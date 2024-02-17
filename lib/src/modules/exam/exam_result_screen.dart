import 'package:collection/collection.dart';
import 'package:drive/src/binding/exam_result_detail_bindings.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/training_screen_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/exam/exam_result_detail_screen.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// ignore: must_be_immutable
class ExamResultScreen extends StatefulWidget {
  int examId;
  bool isFromExam;
  ExamResultScreen({Key? key, required this.examId, required this.isFromExam})
      : super(key: key);

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  RxString doneChaptersPercentage = "".obs;
  RxInt doneChaptersLength = 0.obs;
  RxDouble percentage = 0.0.obs;
  RxList dataByChapter = [].obs;
  RxMap groupOfChapters = {}.obs;
  RxMap examResult = {}.obs;
  RxBool isLoading = true.obs;
  NetworkRepository networkRepository = locator<NetworkRepository>();

  @override
  void initState() {
    if (!isInternetOn.value) {
      offlineData();
    } else {
      getResult(context, widget.examId);
    }
    super.initState();
  }

  getResult(context, examId) async {
    Map resultData = await networkRepository.getExamResult(context, examId);
    if (resultData['statusCode'] == '200' || resultData['statusCode'] == 200) {
      if (resultData['data'] != null) {
        examResult.value = resultData['data'];
        GetStorage().write('lastExamResultData', resultData['data']);
        setData(resultData['data']['examClassQuestions']);
      }
    }
    isLoading.value = false;
  }

  offlineData() {
    if (GetStorage().read('lastExamResultData') != null) {
      examResult.value =
          GetStorage().read('lastExamResultData') as Map<dynamic, dynamic>;
      setData(examResult['examClassQuestions']);
    } else {
      Future.delayed(
        Duration(seconds: 1),
        () => showSnackBar(
          title: currentLanguage['noti_netErrorTitle'],
          message: currentLanguage['noti_netErrorSubtitle'],
          backgroundColor: appColor,
          colorText: whiteColor,
          margin: EdgeInsets.all(30),
        ),
      );
    }
    isLoading.value = false;
  }

  void setData(demosavedData) {
    if (demosavedData.length != 0) {
      groupOfChapters.value = groupBy(demosavedData, (e) {
        Map data = e as Map;
        return data['question']['chapterId'];
      });
      int totalChaptersPoints = 0;
      int correctChaptersPoints = 0;
      for (int i = 0; i < groupOfChapters.values.toList().length; i++) {
        int correctQuestionsPoints = 0;
        int correctQuestionsCount = 0;
        int totalPoints = 0;

        for (var item in groupOfChapters.values.toList()[i]) {
          totalChaptersPoints = totalChaptersPoints +
              int.parse(item['question']['points'].toString());
          totalPoints =
              totalPoints + int.parse(item['question']['points'].toString());
        }

        groupOfChapters.values
            .toList()[i]
            .where((x) => x['isPassed'] == true)
            .toList()
            .forEach((x) {
          correctQuestionsCount++;
          correctQuestionsPoints = correctQuestionsPoints +
              int.parse(x['question']['points'].toString());
          correctChaptersPoints = correctChaptersPoints +
              int.parse(x['question']['points'].toString());
        });

        if (correctQuestionsPoints == totalPoints) {
          doneChaptersLength++;
        }
        dataByChapter.add({
          "chapterId": groupOfChapters.keys.toList()[i],
          "chapterName": groupOfChapters.values.toList()[i][0]['question']
              ['chapter']['name'],
          "questions": groupOfChapters.values.toList()[i],
          "correctQuestionsCount": correctQuestionsCount,
          "correctQuestionsPoints": correctQuestionsPoints,
          "totalPoints": totalPoints,
          "totalQuestions": groupOfChapters.values.toList()[i].length,
        });
      }
      percentage.value = correctChaptersPoints / totalChaptersPoints;
      doneChaptersPercentage.value = "${(percentage.value * 100).ceil()}";
      if (widget.isFromExam) {
        ShowModalsheet.oneButtomModalSheet(
            height: 250,
            title: doneChaptersPercentage.value == '100'
                ? currentLanguage['exam_successTitle']
                : currentLanguage['exam_failTitle'],
            description: doneChaptersPercentage.value == '100'
                ? currentLanguage['exam_successText']
                : currentLanguage['exam_failText'],
            onOkPress: () {
              Get.back();
            },
            okbtnTitle: currentLanguage['global_ok']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        elevation: 0.0,
        title: Obx(
          () => TextAndStyle(
            title: !isLoading.value && examResult.keys.isEmpty
                ? "Result"
                : doneChaptersPercentage.value == '100'
                    ? currentLanguage['result_passed']
                    : currentLanguage['result_failed'],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(() => !isLoading.value
            ? examResult.keys.isEmpty
                ? notDoneExam()
                : examResult['examClassQuestions'].isEmpty
                    ? notDoneExam()
                    : Column(
                        children: [
                          Container(
                            color: whiteColor,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  height: 120,
                                  width: Get.width / 3.5,
                                  child: SfRadialGauge(
                                    animationDuration: 2000,
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
                                          color: appColor.withOpacity(0.20),
                                          thickness: 12,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: double.parse(
                                                '${doneChaptersPercentage.value.split('%').first}'),
                                            cornerStyle: double.parse(
                                                        '${doneChaptersPercentage.value.split('%').first}') ==
                                                    100.0
                                                ? CornerStyle.bothFlat
                                                : CornerStyle.bothCurve,
                                            width: 12,
                                            sizeUnit:
                                                GaugeSizeUnit.logicalPixel,
                                            color: appColor,
                                          ),
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                              positionFactor: 0.15,
                                              widget: Text(
                                                '$doneChaptersPercentage' + '%',
                                                style: TextStyle(
                                                  color: appColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20.0,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: currentLanguage['result_title']
                                                .split(' ')
                                                .first +
                                            ' ' +
                                            currentLanguage['result_title']
                                                .split(' ')[1],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textGrey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' ${doneChaptersLength.value}/${dataByChapter.length}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: appColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: currentLanguage['result_title']
                                            .split('}')
                                            .last,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                TextAndStyle(
                                  title: currentLanguage['result_subtitle'],
                                  color: tabBarText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            itemCount: dataByChapter.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return listTile(data: dataByChapter[index]);
                            },
                          ),
                        ],
                      )
            : SizedBox()),
      ),
    );
  }

  Widget listTile({data}) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ExamResultDetailScreen(
            chapterId: '${data['id']}'.obs,
            chapterName: '${data['chapterName']}'.obs,
            questions: data['questions'],
          ),
          binding: ExamResultDetailBindings(),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(28, 7, 28, 8),
        padding: EdgeInsets.fromLTRB(16, 11, 16, 11),
        width: Get.width,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.06),
              blurRadius: 40,
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextAndStyle(
                      title: "${data['chapterId']}",
                      fontSize: 14,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: Get.width / 1.9,
                      child: TextAndStyle(
                        title: "${data['chapterName']}",
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                TextAndStyle(
                  title:
                      '${data['correctQuestionsCount']}/${data['totalQuestions']}' +
                          currentLanguage['result_correct'].split('}').last,
                  fontSize: 12,
                ),
              ],
            ),
            Container(
              height: 60,
              width: Get.width / 6.5,
              child: SfRadialGauge(
                animationDuration: 2000,
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
                      color: appColor.withOpacity(0.20),
                      thickness: 8,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: data['correctQuestionsPoints'] /
                            data['totalPoints'] *
                            100,
                        cornerStyle: data['correctQuestionsPoints'] /
                                    data['totalPoints'] *
                                    100 ==
                                100.0
                            ? CornerStyle.bothFlat
                            : CornerStyle.bothCurve,
                        width: 8,
                        sizeUnit: GaugeSizeUnit.logicalPixel,
                        color: appColor,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        positionFactor: 0.15,
                        widget: Text(
                          "${(data['correctQuestionsPoints'] / data['totalPoints'] * 100).ceil()}%",
                          style: TextStyle(
                            color: appColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget notDoneExam() {
    return Center(
      child: Container(
        height: Get.height,
        width: Get.width,
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextAndStyle(
              title: currentLanguage['modal_noExamResultTitle'],
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
            GestureDetector(
              onTap: () {
                Get.find<TrainingScreenController>().simulateTestStart(
                  context,
                );
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: appColor,
                ),
                child: TextAndStyle(
                    title: currentLanguage['modal_startExam'],
                    fontFamily: "Rubik",
                    letterSpacing: 0.2,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: primaryWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
