import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  const FullScreenVideo({
    required this.videoPlayerController,
    Key? key,
  }) : super(key: key);

  @override
  State<FullScreenVideo> createState() =>
      _FullScreenVideoState(this.videoPlayerController);
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  final VideoPlayerController videoPlayerController;
  _FullScreenVideoState(this.videoPlayerController);
  @override
  void initState() {
    videoPlayerController.initialize().then((value) {
      videoPlayerController.play();
      videoPlayerController.setLooping(false);
    });
    videoPlayerController.addListener(checkIsFinished);

    super.initState();
  }

  RxBool isBack = true.obs;
  void checkIsFinished() {
    if (isBack.value) {
      if (videoPlayerController.value.duration ==
          videoPlayerController.value.position) {
        Get.back();
        if (!isInternetOn.value) {
          Get.find<QuestionScreenController>().popUpOn.value = false;
          Get.back();
        }
        isBack.value = false;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.removeListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black87,
          body: videoPlayerController.value.isInitialized
              ? videoPlayerController.value.hasError
                  ? Container(
                      height: Get.height,
                      alignment: Alignment.center,
                      child: TextAndStyle(
                        title: videoPlayerController.value.errorDescription,
                      ))
                  : Stack(
                      children: [
                        Center(
                          child: Container(
                            alignment: Alignment.center,
                            height: Get.height > 690 ? 220 : 225,
                            child: VideoPlayer(videoPlayerController),
                          ),
                        ),
                        videoPlayerController.value.isBuffering
                            ? Center(
                                child: CupertinoActivityIndicator
                                    .partiallyRevealed(),
                              )
                            : SizedBox.shrink(),
                        Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                    margin: EdgeInsets.all(18),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: blackColor,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: whiteColor,
                                    )))),
                      ],
                    )
              : Container(
                  height: Get.height,
                  alignment: Alignment.center,
                  child: CupertinoActivityIndicator.partiallyRevealed())),
    );
  }
}
