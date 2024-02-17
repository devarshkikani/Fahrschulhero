import 'package:drive/src/controller/school_detail_controller.dart';
import 'package:get/get.dart';

class SchoolDetailBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SchoolDetailController());
  }
}
