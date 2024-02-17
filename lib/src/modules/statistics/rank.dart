import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/statistics_screen_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/listTile_effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class RankScreen extends GetView<StatisticsScreenController> {
  RankScreen({Key? key}) : super(key: key);
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => controller.leagueID.value != 0
                ? Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        controller.leagueID.value >= 3
                            ? leagueImage((controller.leagueID.value - 2), 50.0)
                            : Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(10),
                              ),
                        controller.leagueID.value >= 2
                            ? leagueImage((controller.leagueID.value - 1), 55.0)
                            : Container(
                                height: 55,
                                width: 55,
                                padding: EdgeInsets.all(10),
                              ),
                        leagueImage(controller.leagueID.value, 65),
                        controller.leagueID.value <= 5
                            ? leagueImage((controller.leagueID.value + 1), 55.0)
                            : Container(
                                height: 55,
                                width: 55,
                                padding: EdgeInsets.all(10),
                              ),
                        controller.leagueID.value <= 4
                            ? leagueImage((controller.leagueID.value + 2), 50.0)
                            : Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(10),
                              ),
                      ],
                    ),
                  )
                : Container(
                    height: 65,
                    alignment: Alignment.center,
                    child: CupertinoActivityIndicator(),
                  )),
            Obx(
              () => TextAndStyle(
                title: controller.userRankData['name'] ?? 'Leagues',
                fontWeight: FontWeight.w400,
                fontSize: 28.0,
                color: bluishgrey,
              ),
            ),
            Container(
              width: Get.width,
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              decoration: BoxDecoration(
                color: appColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 21),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextAndStyle(
                          title: currentLanguage['standings_title'],
                          color: whiteColor,
                        ),
                        if (controller.getStorage.read('uid') != null)
                          FutureBuilder<Uri>(
                            future:
                                controller.dynamicRepository.createDynamicLink(
                              controller.getStorage.read('uid'),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                Uri? uri = snapshot.data;
                                return GestureDetector(
                                  onTap: () {
                                    if (!isInternetOn.value) {
                                      showSnackBar(
                                        title: currentLanguage[
                                            'noti_netErrorTitle'],
                                        message: currentLanguage[
                                            'noti_netErrorSubtitle'],
                                        backgroundColor: appColor,
                                        colorText: whiteColor,
                                        margin: EdgeInsets.all(30),
                                      );
                                    } else {
                                      Share.share(
                                          currentLanguage['link_inviteText'] +
                                              '\n' +
                                              uri.toString());
                                      // Get.to(
                                      //   () => InviteFriendsScreen(),
                                      // );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 7.0, horizontal: 11),
                                    decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: BorderRadius.circular(2)),
                                    child: Obx(() => TextAndStyle(
                                          title: currentLanguage[
                                              'stat_inviteFriend'],
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: appColor,
                                        )),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  Obx(
                    () => controller.isLoading.value == false &&
                            controller.rankList.isEmpty
                        ? Container(
                            height: Get.height * 0.5,
                            alignment: Alignment.center,
                            child: TextAndStyle(
                              title: 'No data found',
                              fontSize: 18,
                              color: blackColor,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.isLoading.value
                                ? 5
                                : controller.rankList.length,
                            padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
                            itemBuilder: (context, index) {
                              if (controller.isLoading.value) {
                                return buildMovieShimmer();
                              } else {
                                return Container(
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: int.parse(controller.getStorage
                                                .read('userId')) ==
                                            controller.rankList[index]['userId']
                                        ? whiteColor
                                        : testColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      index == 0
                                          ? SvgPicture.asset(
                                              "assets/images/medal1.svg")
                                          : index == 1
                                              ? SvgPicture.asset(
                                                  "assets/images/medal2.svg")
                                              : index == 2
                                                  ? SvgPicture.asset(
                                                      "assets/images/medal3.svg")
                                                  : Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10, right: 7.0),
                                                      child: TextAndStyle(
                                                          title: (index + 1)
                                                              .toString(),
                                                          color: int.parse(controller
                                                                      .getStorage
                                                                      .read(
                                                                          'userId')) ==
                                                                  controller.rankList[
                                                                          index]
                                                                      ['userId']
                                                              ? black15
                                                              : primaryWhite,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Container(
                                          height: 36,
                                          width: 36,
                                          child: controller.rankList[index]
                                                      ['photoUrl'] ==
                                                  null
                                              ? Image.asset(
                                                  "assets/images/default/profile.jpeg",
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      '${controller.rankList[index]['photoUrl']}',
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => Center(
                                                      child: CupertinoActivityIndicator
                                                          .partiallyRevealed()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      TextAndStyle(
                                          title: controller.rankList[index]
                                              ['firstName'],
                                          color: int.parse(controller.getStorage
                                                      .read('userId')) ==
                                                  controller.rankList[index]
                                                      ['userId']
                                              ? appColor
                                              : primaryWhite,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      Spacer(),
                                      Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          color: int.parse(controller.getStorage
                                                      .read('userId')) ==
                                                  controller.rankList[index]
                                                      ['userId']
                                              ? appColor.withOpacity(0.20)
                                              : index == 0
                                                  ? greenColor
                                                  : primaryWhite
                                                      .withOpacity(0.20),
                                        ),
                                        child: TextAndStyle(
                                          title: controller.rankList[index]
                                                      ['points']
                                                  .toString() +
                                              ' ' +
                                              currentLanguage['short_points'],
                                          textAlign: TextAlign.center,
                                          color: int.parse(controller.getStorage
                                                      .read('userId')) ==
                                                  controller.rankList[index]
                                                      ['userId']
                                              ? appColor
                                              : primaryWhite,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget leagueImage(id, double size) {
    return CachedNetworkImage(
      imageUrl: "${_appConstants.imageEndPoint}/Ranks/${id}_v1.png",
      height: size,
      width: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        padding: EdgeInsets.all(20),
        child: CupertinoActivityIndicator(),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Widget buildMovieShimmer() => ListTile(
        leading: CustomWidget.circular(height: 64, width: 64),
        title: Align(
          alignment: Alignment.centerLeft,
          child: CustomWidget.rectangular(
            height: 16,
            width: Get.width * 0.3,
          ),
        ),
        subtitle: CustomWidget.rectangular(height: 14),
      );
}
