import 'dart:developer';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ExamResultDetailController extends GetxController {
  RxList allQuestions = [].obs;
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();
  RxList<RxMap<String, VideoPlayerController>> videoControllerList =
      <RxMap<String, VideoPlayerController>>[].obs;

  getAllQuestions(questions) async {
    videoControllerList.clear();
    allQuestions.value = questions;
    for (int i = 0; i < allQuestions.length; i++) {
      if (allQuestions[i]['question']['hasVideo'] == true) {
        final VideoPlayerController _videoController =
            VideoPlayerController.network(
                '${_appConstants.imageEndPoint}/Common/Photos/Questions/${allQuestions[i]['question']['questionId']}.m4v');
        _videoController.addListener(() {});
        _videoController.setLooping(true);
        if (_videoController.value.hasError) {
          log(_videoController.value.hasError.toString());
        } else {
          await _videoController.initialize().then((_) {
            videoControllerList.add({
              '${allQuestions[i]['question']['questionId']}': _videoController
            }.obs);
            update();
          });
        }
      }
    }
    update();
  }

  videoInitialize(index) {
    for (int i = 0; i < videoControllerList.length; i++) {
      if (i != index) {
        videoControllerList[i].values.toList()[0].pause();
      }
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }
}
