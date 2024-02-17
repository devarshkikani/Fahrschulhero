import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/exam_result_detail_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/Questions/option_decoration.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class ExamResultDetailScreen extends GetView<ExamResultDetailController> {
  final RxString chapterId;
  final RxString chapterName;
  final List questions;
  ExamResultDetailScreen(
      {Key? key,
      required this.chapterId,
      required this.chapterName,
      required this.questions})
      : super(key: key);

  final ApiEndpoints _appConstants = locator<ApiEndpoints>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamResultDetailController>(
      initState: (state) => controller.getAllQuestions(questions),
      builder: (_) {
        return Scaffold(
            backgroundColor: appBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: appColor,
              title: TextAndStyle(
                title: chapterName.value,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              elevation: 0.0,
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            body: ListView.builder(
                itemCount: controller.allQuestions.length,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  return tileDecoration(
                      context: context,
                      questionData: controller.allQuestions[index]);
                }));
      },
    );
  }

  Widget tileDecoration(
      {required Map questionData, required BuildContext context}) {
    List listofAns = [];
    RxString differentAnswer = ''.obs;
    String correctAnswer = '';
    if (questionData['question']['answer2'] != null) {
      List answers =
          questionData['question']['solution'].toString().split('').toList();
      for (int i = 0; i < answers.length; i++) {
        if (answers[i] == '1') {
          correctAnswer = correctAnswer + String.fromCharCode(65 + i);
        }
      }
      differentAnswer.value = correctAnswer.split('').join(',');
    } else {
      differentAnswer.value = questionData['question']['solution'] +
              ' ' +
              questionData['question']['answer3'] ??
          '';
    }
    for (int j = 0; j < 3; j++) {
      if (questionData['question']['answer2'] != null) {
        if (questionData['question']['answer${j + 1}'] != null) {
          listofAns.add({
            questionData['question']['answer${j + 1}'].toString().obs:
                questionData['question']['solution'][j].toString().obs
          });
        }
      }
      //  else {
      //   differentAnswer.value = questionData['question']['solution'];
      // }
    }
    final index = controller.videoControllerList.indexWhere(
        (p0) => p0.keys.single == questionData['question']['questionId']);
    String question3 = questionData['question']['answer3'] ?? '';
    return Container(
      // padding: EdgeInsets.all(15),
      margin: EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: questionData['isPassed'] == true
            ? appColor.withOpacity(0.10)
            : red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: TextAndStyle(
            title: questionData['question']['title'],
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: blackColor,
          ),
          tilePadding: EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
          childrenPadding: EdgeInsets.zero,
          iconColor: blackColor,
          collapsedIconColor: blackColor,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 0),
              child: questionData['question']['hasPicture']
                  ? CachedNetworkImage(
                      height: Get.width / 1.6,
                      width: Get.width,
                      imageUrl:
                          '${_appConstants.imageEndPoint}/Common/Photos/Questions/${questionData['question']['questionId']}.jpg',
                      // placeholder: (context, url) => Center(
                      //     child:
                      //         CupertinoActivityIndicator.partiallyRevealed()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : questionData['question']['hasVideo']
                      ? Container(
                          height: Get.height * 0.23,
                          margin: EdgeInsets.only(bottom: 15),
                          child: index != -1
                              ? VideoWidget(
                                  controller: controller
                                      .videoControllerList[index].values
                                      .toList()[0],
                                  questionId: controller
                                      .videoControllerList[index].keys
                                      .toList()[0],
                                  index: index != -1 ? index : null,
                                  play: false)
                              : Center(
                                  child: CupertinoActivityIndicator
                                      .partiallyRevealed()),
                        )
                      : SizedBox(),
            ),
            questionData['question']['answer2'] == null
                ? Padding(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 10, bottom: 0),
                    child: Row(
                      children: [
                        TextAndStyle(
                          title: questionData['givenAnswer'] + ' ' + question3,
                          fontSize: 14,
                          color: blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                        Spacer(),
                        questionData['isPassed'] == true
                            ? Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Image.asset("assets/icons/right.png"),
                              )
                            : Padding(
                                padding: EdgeInsets.only(right: 12.0),
                                child: Image.asset("assets/icons/wrong.png"),
                              )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: listofAns.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: OptionDecoration(
                          index: index,
                          optionIndex: String.fromCharCode(65 + index),
                          overview: true,
                          option: listofAns[index],
                          givenAnswer: questionData['givenAnswer'],
                        ),
                      );
                    },
                  ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 42,
              width: Get.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: questionData['isPassed'] == true
                    ? appColor.withOpacity(0.10)
                    : red.withOpacity(0.10),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: TextAndStyle(
                title: '${currentLanguage['question_correctAnswer']} ' +
                    differentAnswer.value,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final bool play;
  final String questionId;
  final VideoPlayerController? controller;
  final int? index;
  VideoWidget(
      {Key? key,
      required this.play,
      required this.questionId,
      required this.controller,
      required this.index})
      : super(key: key);
  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.controller!.value.isPlaying) {
          widget.controller!.pause();
        } else {
          await Get.find<ExamResultDetailController>()
              .videoInitialize(widget.index);
          widget.controller!.play();
        }
        setState(() {});
      },
      child: Stack(
        children: [
          VideoPlayer(
            widget.controller!,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 50),
              reverseDuration: Duration(milliseconds: 200),
              child: widget.controller!.value.isPlaying
                  ? SizedBox.shrink()
                  : Container(
                      color: Colors.black26,
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 60.0,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
