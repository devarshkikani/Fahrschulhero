import 'package:drive/src/controller/exam_result_detail_controller.dart';
import 'package:get/instance_manager.dart';

class ExamResultDetailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExamResultDetailController());
  }
}
