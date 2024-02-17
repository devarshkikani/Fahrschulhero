import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/validator.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:drive/src/widgets/show_video_full_screen.dart';
import 'package:drive/src/widgets/text_widgets/input_text_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:video_player/video_player.dart';
import '../option_decoration.dart';
import '../questions_screen.dart';

// ignore: must_be_immutable
class QuestionPageBuilder extends StatefulWidget {
  RxString question;
  RxList answers;
  RxString questionId;
  RxString chapterId;
  RxString differentAnswer;
  RxString nextQuestionId;
  RxBool hasVideo;
  RxBool hasPicture;
  bool simulateExam;
  String? subitle;
  String? givenAnswer;
  RxInt? watchCounter;
  int points;
  QuestionScreenController questionScreenController;
  QuestionPageBuilder({
    required this.question,
    required this.answers,
    required this.differentAnswer,
    required this.questionId,
    required this.chapterId,
    required this.nextQuestionId,
    required this.hasVideo,
    required this.hasPicture,
    required this.simulateExam,
    required this.questionScreenController,
    this.subitle,
    this.givenAnswer,
    this.points = 0,
    this.watchCounter,
  });

  @override
  State<QuestionPageBuilder> createState() => _QuestionPageBuilderState();
}

class _QuestionPageBuilderState extends State<QuestionPageBuilder> {
  RxBool isCorrected = false.obs;
  RxList correctLatters = [].obs;
  RxString userEnterAnswer = ''.obs;
  DatabaseHelper databaseHelper = DatabaseHelper();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();
  final _controller = Get.put(QuestionScreenController());
  Rx<TextEditingController> textEditingController =
      Rx<TextEditingController>(TextEditingController());
  Rx<VideoPlayerController>? videoController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map<String, String> correctAnswers = {};
  RxBool isInitialize = false.obs;
  RxBool isPlay = false.obs;
  RxBool isBuffering = false.obs;
  RxBool hideQuestions = true.obs;
  RxBool showVideo = true.obs;
  RxBool hasError = false.obs;

  @override
  void initState() {
    initialization();
    if (widget.simulateExam) {
      hideQuestions.value = widget.watchCounter!.value > 0 ? true : false;
    }
    super.initState();
  }

  @override
  void dispose() {
    videoController?.value.dispose();
    super.dispose();
  }

  void initialization() async {
    if (widget.differentAnswer == ''.obs) {
      for (int i = 0; i < widget.answers.length; i++) {
        seletedMap[String.fromCharCode(65 + i)] = '0';
        if (widget.givenAnswer != null) {
          seletedMap[String.fromCharCode(65 + i)] =
              widget.givenAnswer!.split("").toList()[i];
        }
      }
    } else {
      if (widget.givenAnswer != null) {
        if (widget.questionScreenController.textEditingController.value.text ==
                widget.givenAnswer ||
            widget.questionScreenController.textEditingController.value.text ==
                "") {
          widget.questionScreenController.textEditingController.value.text =
              widget.givenAnswer!;
        }
      }
    }
    if (widget.hasVideo.value) {
      await videoInitialize(widget.questionId.value);
    }
  }

  videoInitialize(String questionId) {
    isInitialize.value = false;
    if (videoController != null) {
      videoController!.value.dispose();
    }
    videoController = VideoPlayerController.network(
            '${_appConstants.imageEndPoint}/Common/Photos/Questions/$questionId.m4v')
        .obs;
    videoController!.value.addListener(() {
      if (videoController!.value.value.hasError) {
        hasError.value = true;
        isInitialize.value = true;
      }
      if (videoController!.value.value.isBuffering) {
        isBuffering.value = true;
      } else {
        isBuffering.value = false;
      }
    });
    videoController!.value.setLooping(true);
    videoController!.value.initialize().then((_) {
      videoController!.value.pause();
      isPlay.value = false;
      isInitialize.value = true;
    });
  }

  videoPlayPause() {
    if (videoController!.value.value.isPlaying) {
      videoController!.value.pause();
      isPlay.value = false;
    } else {
      videoController!.value.play();
      isPlay.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
                    child: TextAndStyle(
                        title: widget.question.value,
                        fontSize: 14,
                        fontFamily: "Rubik",
                        color: tabBarText,
                        fontWeight: FontWeight.w500),
                  ),
                  if (widget.subitle != '')
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          18, 0, 18, widget.hasPicture.value ? 14 : 16),
                      child: TextAndStyle(
                          title: widget.subitle,
                          fontSize: 14,
                          fontFamily: "Rubik",
                          color: tabBarText,
                          fontWeight: FontWeight.w400),
                    ),
                  widget.hasPicture.value
                      ? Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16.0,
                          ),
                          child: CachedNetworkImage(
                            height: Get.width / 1.6,
                            width: Get.width,
                            imageUrl:
                                '${_appConstants.imageEndPoint}/Common/Photos/Questions/${widget.questionId}.jpg',
                            // placeholder: (context, url) => Center(
                            //     child:
                            //         CupertinoActivityIndicator.partiallyRevealed()),
                            errorWidget: (context, url, error) => IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.error),
                            ),
                          ),
                        )
                      : widget.hasVideo.value
                          ? Obx(() => showVideo.value
                              ? isInitialize.value
                                  ? hasError.value
                                      ? Container(
                                          height: 200,
                                          padding: EdgeInsets.fromLTRB(
                                              18, 0, 18, 14),
                                          alignment: Alignment.center,
                                          child: TextAndStyle(
                                            title: videoController!
                                                .value.value.errorDescription,
                                            // textAlign: TextAlign.center,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            if (!widget.simulateExam) {
                                              videoPlayPause();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 0, 14),
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      height: Get.height > 690
                                                          ? 220
                                                          : 225,
                                                      child: VideoPlayer(
                                                        videoController!.value,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: AnimatedSwitcher(
                                                        duration: Duration(
                                                            milliseconds: 50),
                                                        reverseDuration:
                                                            Duration(
                                                                milliseconds:
                                                                    200),
                                                        child:
                                                            //  Obx(() =>
                                                            isBuffering.value
                                                                ? CupertinoActivityIndicator
                                                                    .partiallyRevealed()
                                                                : isPlay.value ||
                                                                        widget
                                                                            .simulateExam
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Container(
                                                                        color: Colors
                                                                            .black26,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Icon(
                                                                            Icons.play_circle_outline,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                60.0,
                                                                          ),
                                                                        ),
                                                                      ),
                                                      ),
                                                      // ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                  : Container(
                                      height: 200,
                                      alignment: Alignment.center,
                                      child: CupertinoActivityIndicator
                                          .partiallyRevealed())
                              : Container())
                          : Container(),
                  Obx(
                    () => widget.hasVideo.value &&
                            widget.simulateExam &&
                            hideQuestions.value
                        ? isInitialize.value
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 18, 18, 0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          showVideo.value = false;
                                          _controller
                                              .questions[_controller
                                                  .currentQuestionIndex
                                                  .value]["watchCounter"]
                                              .value--;
                                          Get.to(() => FullScreenVideo(
                                                  videoPlayerController:
                                                      videoController!.value))
                                              ?.then((value) {
                                            initialization();
                                            showVideo.value = true;
                                            if (_controller
                                                    .questions[_controller
                                                        .currentQuestionIndex
                                                        .value]["watchCounter"]
                                                    .value <=
                                                0) hideQuestions.value = false;
                                            if (!isInternetOn.value) {
                                              if (!Get.find<
                                                      QuestionScreenController>()
                                                  .popUpOn
                                                  .value) {
                                                Get.find<
                                                        QuestionScreenController>()
                                                    .popUpOn
                                                    .value = true;
                                                ShowModalsheet
                                                    .oneButtomModalSheet(
                                                        height: 230,
                                                        title: currentLanguage[
                                                            'noti_netErrorTitle'],
                                                        description:
                                                            currentLanguage[
                                                                'noti_waitNetMsg'],
                                                        onOkPress: () {
                                                          select.clear();
                                                          seletedMap.clear();
                                                          nextQuestion.value =
                                                              false;
                                                          Get.find<
                                                                  QuestionScreenController>()
                                                              .currentQuestionIndex
                                                              .value = 0;
                                                          Get.find<
                                                                  QuestionScreenController>()
                                                              .timer
                                                              .cancel();
                                                          Get.back();
                                                          Get.back();
                                                        },
                                                        okbtnTitle: currentLanguage[
                                                            'noti_waitNetBtn']);
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 11),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            border:
                                                Border.all(color: bordergrey),
                                          ),
                                          child: TextAndStyle(
                                            title:
                                                "${currentLanguage['exam_watchVideo']} ${widget.watchCounter == 3.obs ? '(3)' : '(${widget.watchCounter})'}",
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          hideQuestions.value = false;
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 11),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: greenColor,
                                          ),
                                          child: TextAndStyle(
                                            title: currentLanguage[
                                                'exam_showQuestion'],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: whiteColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container()
                        : widget.differentAnswer.value == ''
                            ? ListView.separated(
                                itemCount: widget.answers
                                    .where((element) {
                                      return element.keys.toString() ==
                                                  '(null)' ||
                                              element.keys.toString() ==
                                                  'null' ||
                                              element.keys.toString() == '()'
                                          ? false
                                          : true;
                                    })
                                    .toList()
                                    .length,
                                separatorBuilder: (_, int i) => SizedBox(
                                  height: 12,
                                ),
                                // padding: EdgeInsets.symmetric(vertical: 12.0),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return OptionDecoration(
                                    index: index,
                                    optionIndex:
                                        String.fromCharCode(65 + index),
                                    option: widget.answers[index],
                                    isFromExam: widget.simulateExam,
                                  );
                                },
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 12, 28, 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextAndStyle(
                                      title: widget.answers[0].keys
                                          .toList()[0]
                                          .toString(),
                                      fontSize: 12,
                                      color: blackColor,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Form(
                                      key: widget.simulateExam == true
                                          ? widget
                                              .questionScreenController.formKey
                                          : formKey,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormFieldWidget(
                                              controller: widget.simulateExam ==
                                                      true
                                                  ? Get.find<
                                                          QuestionScreenController>()
                                                      .textEditingController
                                                      .value
                                                  : textEditingController.value,
                                              filledColor: whiteColor,
                                              onChanged: (value) {
                                                userEnterAnswer.value = value!;
                                              },
                                              inputFormatters: [
                                                ReplaceCommaFormatter(),
                                              ],
                                              cursorColor: blackColor,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              textInputAction:
                                                  TextInputAction.done,
                                              focusBorder: BorderSide(
                                                color: bordergrey,
                                              ),
                                              border: BorderSide(
                                                color: bordergrey,
                                              ),
                                              enabledBorder: BorderSide(
                                                color: bordergrey,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          if (widget.answers.length > 1)
                                            TextAndStyle(
                                              title: widget.answers[1].keys
                                                  .toList()[0]
                                                  .toString(),
                                              fontSize: 12,
                                              color: blackColor,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          if (widget.simulateExam != true)
            Column(
              children: [
                Obx(
                  () => nextQuestion.value
                      ? Container(
                          height: 46.0,
                          width: Get.width,
                          margin: EdgeInsets.only(bottom: 12.0),
                          alignment: Alignment.center,
                          color: isCorrected.value ? greenColor : redColor,
                          child: TextAndStyle(
                            title: widget.differentAnswer.value == ''
                                ? "${currentLanguage['question_correctAnswer']} ${correctLatters.map((e) => e.key).toString().split('(')[1].split(')')[0].toString()}"
                                : "${currentLanguage['question_correctAnswer']} ${widget.differentAnswer}",
                            color: whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        )
                      : SizedBox(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _controller.previousButton();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.symmetric(horizontal: 22),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: Obx(
                            () => select.keys.isNotEmpty ||
                                    userEnterAnswer.value != ""
                                ? nextQuestion.value
                                    ? nextQuestionWidget(context)
                                    : buttondecoration(
                                        onTap: () async {
                                          if (widget.differentAnswer.value ==
                                              '') {
                                            correctAnswers.clear();
                                            for (int i = 0;
                                                i < widget.answers.length;
                                                i++) {
                                              correctAnswers[
                                                  String.fromCharCode(
                                                      65 + i)] = widget
                                                  .answers[i].values
                                                  .toList()[0]
                                                  .toString();
                                            }
                                            correctLatters.value =
                                                correctAnswers.entries
                                                    .where((element) => element
                                                                .value
                                                                .toString() ==
                                                            '1'
                                                        ? true
                                                        : false)
                                                    .toList();
                                            if (correctAnswers.toString() ==
                                                seletedMap.toString()) {
                                              isCorrected.value = true;
                                            } else {
                                              isCorrected.value = false;
                                            }
                                          } else {
                                            if (formKey.currentState!
                                                .validate()) {
                                              FocusScope.of(context).unfocus();
                                              isCorrected.value = (widget
                                                      .differentAnswer.value ==
                                                  textEditingController
                                                      .value.text);
                                            }
                                          }
                                          log(widget.chapterId.toString() +
                                              " :::: ");
                                          await databaseHelper.questionUpdate(
                                            widget.questionId.toString(),
                                            isCorrected.value,
                                            _controller.isFromHome.value &&
                                                    Get.find<HomeController>()
                                                        .doneChapters
                                                        .contains(_controller
                                                            .currentChapter
                                                            .value)
                                                ? widget.nextQuestionId
                                                    .toString()
                                                : '',
                                            widget.chapterId.toString(),
                                          );
                                          log('isCorrect: ${isCorrected.value}');
                                          if (isCorrected.value) {
                                            widget.questionScreenController
                                                .pointsAchieved.value = widget
                                                    .questionScreenController
                                                    .pointsAchieved
                                                    .value +
                                                widget.points;
                                            widget.questionScreenController
                                                .questionsCorrect.value++;
                                          }
                                          if (isInternetOn.value) {
                                            _networkRepository.answer(null, {
                                              "questionId":
                                                  widget.questionId.toString(),
                                              "isCorrect": isCorrected.value
                                            });
                                          } else {
                                            offlineAnswered.add({
                                              "questionId":
                                                  widget.questionId.toString(),
                                              "isCorrect": isCorrected.value
                                            });
                                            GetStorage().write(
                                                'pendingAnsweredQuestions',
                                                offlineAnswered);
                                          }
                                          if (_controller.questionCount.value <
                                              5) {
                                            _controller.questionCount++;
                                          } else {
                                            _controller.isShowReview();
                                            _controller.questionCount.value = 0;
                                          }
                                          seletedMap.clear();
                                          nextQuestion.value = true;
                                        },
                                        title:
                                            currentLanguage['question_answer'],
                                      )
                                : Obx(() => nextQuestion.value
                                    ? nextQuestionWidget(context)
                                    : SizedBox()),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _controller.doneOrSkipButton(false, true);
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.symmetric(horizontal: 22),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget nextQuestionWidget(context) {
    return buttondecoration(
      onTap: () {
        if ((_controller.currentQuestionIndex.value + 1) ==
                _controller.questions.length &&
            !_controller.isFromHome.value) {
          _controller.backButton(0.0.obs);
        } else {
          _controller.doneOrSkipButton(false, false);
        }
      },
      title: (_controller.currentQuestionIndex.value + 1) ==
              _controller.questions.length
          ? currentLanguage['global_done']
          : currentLanguage['question_nextQuestion'],
    );
  }
}

Widget buttondecoration({String? title, VoidCallback? onTap}) {
  return ElevatedButton(
    onPressed: onTap,
    style: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    ),
    child: TextAndStyle(
      title: title,
      fontFamily: "Rubik",
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: 0.2,
    ),
  );
}
