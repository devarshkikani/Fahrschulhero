import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/utils/dynamic_link_service.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

RxInt tabIndex = 0.obs;

class StatisticsScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? topTabController;
  RxDouble numberOfFeatures = 7.0.obs;
  RxInt points = 0.obs;
  DatabaseHelper databaseHelper = DatabaseHelper();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  GetStorage getStorage = GetStorage();
  RxMap userRankData = {}.obs;
  RxList rankList = [].obs;
  RxBool isLoading = true.obs;
  RxInt leagueID = 0.obs;
  DynamicRepository dynamicRepository = locator<DynamicRepository>();

  @override
  void onInit() {
    super.onInit();
    topTabController =
        TabController(length: 2, vsync: this, initialIndex: tabIndex.value);
  }

  @override
  void dispose() {
    topTabController!.dispose();
    super.dispose();
  }

  getPoints() async {
    points.value = 0;
    List correctAnsweredQuestions =
        await databaseHelper.getCorrectAnsweredQuestions();
    for (int i = 0; i < correctAnsweredQuestions.length; i++) {
      points.value = (correctAnsweredQuestions[i]['points'] *
              correctAnsweredQuestions[i]['correct']) +
          points.value;
    }
  }

  getusersRank() async {
    Map? userlist = await _networkRepository.getUsersRank(null);
    if (userlist != null) {
      if (userlist['statusCode'] == 200) {
        userRankData.value = userlist['data'];
        leagueID.value = userlist['data']['id'];
        rankList.value = userlist['data']['users'];
        rankList.sort(
          (a, b) {
            return (b['points'].compareTo(a['points']));
          },
        );
        for (int i = 0; i < rankList.length; i++) {
          if (int.parse(getStorage.read('userId')) == rankList[i]['userId']) {
            getStorage.write('userPosition', i + 1);
          }
        }
        isLoading.value = false;
      }
    }
  }
}
