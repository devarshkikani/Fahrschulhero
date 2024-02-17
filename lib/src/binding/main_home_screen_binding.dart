import 'package:drive/src/controller/school_list_controller.dart';
import 'package:drive/src/controller/statistics_screen_controller.dart';
import 'package:drive/src/controller/training_screen_controller.dart';
import 'package:drive/src/controller/main_home_controller.dart';
import 'package:get/get.dart';
import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/settings_screen_controller.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeController>(() => MainHomeController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TrainingScreenController>(() => TrainingScreenController());
    Get.put(StatisticsScreenController());
    Get.lazyPut<SettingScreenController>(() => SettingScreenController());
    Get.lazyPut<SchoolListController>(() => SchoolListController());
  }
}
