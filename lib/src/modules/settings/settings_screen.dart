import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/settings_screen_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/settings/class_screen.dart';
import 'package:drive/src/modules/subscription/in_app_purchase.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/dynamic_link_service.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/validator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/text_widgets/input_text_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class SettingsScreen extends GetView<SettingScreenController>
    with WidgetsBindingObserver {
  DynamicRepository _dynamicRepository = locator<DynamicRepository>();

  String helpEmail = "info@fahrschulhero.de";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 30, top: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.updateProfilePic(context),
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Obx(
                                () => SizedBox(
                                  height: 83,
                                  width: 83,
                                  child: controller.selectedImagePath.value ==
                                          ''
                                      ? controller.getStorage
                                                  .read('photoUrl')
                                                  .toString() !=
                                              'null'
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  '${controller.getStorage.read('photoUrl')}',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      const CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            )
                                          : Image.asset(
                                              "assets/images/default/profile.jpeg",
                                            )
                                      : Image.file(
                                          File(controller
                                              .selectedImagePath.value),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => controller.updateProfilePic(context),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                    color: appColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: whiteColor, width: 2.0)),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => TextAndStyle(
                              title: '${controller.firstName}',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0,
                            )),
                        SizedBox(height: 8),
                        Obx(
                          () => !controller.isSubscribe.value
                              ? TextAndStyle(
                                  title: currentLanguage['home_basicMember'],
                                  textAlign: TextAlign.left,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0,
                                  letterSpacing: 1.5)
                              : TextAndStyle(
                                  title: currentLanguage['home_plusMember'],
                                  textAlign: TextAlign.left,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.0,
                                  letterSpacing: 1.5,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              profileWidget(),
              SizedBox(height: 30),
              generalWidget(),
              SizedBox(height: 30),
              helpCenter(),
              SizedBox(height: 30),
              Obx(
                () => titleWidget(
                  title: currentLanguage['profile_logout'],
                  onTap: () {
                    if (!isInternetOn.value) {
                      showSnackBar(
                        title: currentLanguage['noti_netErrorTitle'],
                        message: currentLanguage['noti_netErrorSubtitle'],
                        backgroundColor: appColor,
                        colorText: whiteColor,
                        margin: EdgeInsets.all(30),
                      );
                    } else {
                      controller.signOut(context);
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              Obx(
                () => titleWidget(
                  title: currentLanguage['profile_delete'],
                  onTap: () {
                    if (!isInternetOn.value) {
                      showSnackBar(
                        title: currentLanguage['noti_netErrorTitle'],
                        message: currentLanguage['noti_netErrorSubtitle'],
                        backgroundColor: appColor,
                        colorText: whiteColor,
                        margin: EdgeInsets.all(30),
                      );
                    } else {
                      controller.deletAccount(context);
                    }
                  },
                ),
              ),
              Obx(
                () => controller.appVersionAndEnvironment.value != ''
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                        child: Center(
                          child: TextAndStyle(
                            title: 'S-' +
                                controller.appVersionAndEnvironment.value +
                                ':C-' +
                                controller.globalSingleton.appVersion,
                            color: textGreyColor,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileWidget() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(title: currentLanguage['profile_title']),
          SizedBox(height: 20),
          cardDecorationWidget(
              child: Column(
            children: [
              listTileItem(
                svgImage: 'assets/icons/svg_icons/user.svg',
                title: currentLanguage['profile_name'],
                titleWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLanguage['profile_name'],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${controller.firstName}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                switchBtn: SizedBox(
                  width: 50,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16.0,
                    ),
                  ),
                ),
                onTap: () {
                  controller.firstNameController.text =
                      controller.firstName.value;
                  controller.modalSheetHeight.value = 230.0;
                  editNameModelSheet();
                },
              ),
              controller.commonWidget.horizontalDivider(),
              listTileItem(
                  svgImage: 'assets/icons/svg_icons/half_heart.svg',
                  title: currentLanguage['global_email'],
                  titleWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLanguage['global_email'],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${controller.getStorage.read('email')}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  switchBtn: SizedBox(
                    width: 1,
                  ),
                  onTap: null),
              controller.commonWidget.horizontalDivider(),
              listTileItem(
                svgImage: 'assets/icons/svg_icons/chart_pie.svg',
                title: currentLanguage['profile_manage'],
                onTap: () {
                  if (!isInternetOn.value) {
                    showSnackBar(
                      title: currentLanguage['noti_netErrorTitle'],
                      message: currentLanguage['noti_netErrorSubtitle'],
                      colorText: whiteColor,
                      margin: EdgeInsets.all(30),
                    );
                  } else {
                    Get.to(
                      () => ClassScreen(isformLogin: false),
                    )?.then((value) {
                      controller.update();
                    });
                  }
                },
              ),
              controller.commonWidget.horizontalDivider(),
              listTileItem(
                svgImage: 'assets/icons/svg_icons/book.svg',
                title: currentLanguage['lbl_examAfterDate']
                        .toString()
                        .split('{0}')
                        .first +
                    controller.versionDate.value,
                switchBtn: dateTimeSwitchBtn(),
                onTap: () {
                  controller.dateTimeValueChange();
                },
              ),
              !controller.isSubscribe.value
                  ? Column(
                      children: [
                        controller.commonWidget.horizontalDivider(),
                        listTileItem(
                            svgImage: 'assets/icons/svg_icons/half_star.svg',
                            title: currentLanguage['profile_upgrade'],
                            onTap: () {
                              if (!isInternetOn.value) {
                                showSnackBar(
                                  title: currentLanguage['noti_netErrorTitle'],
                                  message:
                                      currentLanguage['noti_netErrorSubtitle'],
                                  backgroundColor: appColor,
                                  colorText: whiteColor,
                                  margin: EdgeInsets.all(30),
                                );
                              } else {
                                Get.to(() => SubscriptionScreen());
                              }
                            }),
                      ],
                    )
                  : SizedBox(),
            ],
          )),
        ],
      ),
    );
  }

  Widget generalWidget() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget(title: currentLanguage['profile_general']),
            SizedBox(height: 20),
            cardDecorationWidget(
              child: Column(
                children: [
                  listTileItem(
                    svgImage: 'assets/icons/svg_icons/notifications.svg',
                    title: currentLanguage['profile_learnReminder'],
                    switchBtn: switchBtn(),
                    onTap: () {
                      controller.switchChange();
                    },
                  ),
                  controller.commonWidget.horizontalDivider(),
                  listTileItem(
                      svgImage: 'assets/icons/svg_icons/chart_pie.svg',
                      title: currentLanguage['profile_rate'],
                      onTap: () {
                        if (!isInternetOn.value) {
                          showSnackBar(
                            title: currentLanguage['noti_netErrorTitle'],
                            message: currentLanguage['noti_netErrorSubtitle'],
                            backgroundColor: appColor,
                            colorText: whiteColor,
                            margin: EdgeInsets.all(30),
                          );
                        } else {
                          LaunchReview.launch(
                            androidAppId: 'com.Fahrschulhero',
                            iOSAppId: '1599075528',
                          );
                        }
                      }),
                  if (GetStorage().read('uid') != null)
                    controller.commonWidget.horizontalDivider(),
                  if (GetStorage().read('uid') != null)
                    FutureBuilder<Uri>(
                      future: _dynamicRepository.createDynamicLink(
                        GetStorage().read('uid'),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Uri? uri = snapshot.data;
                          return listTileItem(
                              svgImage: 'assets/icons/svg_icons/half_heart.svg',
                              title: currentLanguage['profile_share'],
                              onTap: () {
                                Share.share(uri.toString());
                              });
                        } else {
                          return Container();
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget helpCenter() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget(title: currentLanguage['profile_help']),
            SizedBox(height: 20),
            cardDecorationWidget(
              child: Column(
                children: [
                  listTileItem(
                    svgImage: 'assets/icons/svg_icons/half_star.svg',
                    title: currentLanguage['help_contactUs'],
                    onTap: () {
                      launch("mailto:$helpEmail");
                    },
                  ),
                  controller.commonWidget.horizontalDivider(),
                  listTileItem(
                      svgImage: 'assets/icons/svg_icons/half_heart.svg',
                      title: currentLanguage['help_terms'],
                      onTap: () {
                        launch(currentLanguage['link_terms']);
                      }),
                  controller.commonWidget.horizontalDivider(),
                  listTileItem(
                      svgImage: 'assets/icons/svg_icons/chart_pie.svg',
                      title: currentLanguage['help_privacy'],
                      onTap: () {
                        launch(currentLanguage['link_privacy']);
                      }),
                ],
              ),
            ),
          ],
        ));
  }

  Widget cardDecorationWidget({required Widget child}) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget titleWidget({required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: TextAndStyle(
        title: "$title".toUpperCase(),
        fontSize: 12,
        color: appColor,
      ),
    );
  }

  Widget listTileItem({
    required String svgImage,
    required String title,
    String? leadingText,
    VoidCallback? onTap,
    Widget? titleWidget,
    Widget? switchBtn,
  }) {
    return ListTile(
      horizontalTitleGap: -5,
      contentPadding: EdgeInsets.fromLTRB(15, 2, 15, 2),
      leading: SvgPicture.asset(
        '$svgImage',
      ),
      title: titleWidget ?? Text('$title'),
      trailing: leadingText != null
          ? Container(
              width: 200,
              alignment: Alignment.centerRight,
              child: Text(
                leadingText,
              ),
            )
          : switchBtn ??
              Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 28,
              ),
      onTap: onTap,
    );
  }

  Widget switchBtn() {
    return SizedBox(
      width: 50,
      height: 32,
      child: FittedBox(
        fit: BoxFit.fill,
        child: CupertinoSwitch(
          activeColor: appColor,
          value: controller.reminder.value,
          onChanged: (value) {
            controller.switchChange();
          },
        ),
      ),
    );
  }

  Widget dateTimeSwitchBtn() {
    return SizedBox(
      width: 50,
      height: 32,
      child: FittedBox(
        fit: BoxFit.fill,
        child: CupertinoSwitch(
          activeColor: appColor,
          value: controller.dateTimeValue.value,
          onChanged: (value) {
            controller.dateTimeValueChange();
          },
        ),
      ),
    );
  }

  void editNameModelSheet() {
    Get.bottomSheet(
      bottomSheetWidget(),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      backgroundColor: whiteColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    );
  }

  Widget bottomSheetWidget() {
    return Obx(() => Container(
          height: controller.modalSheetHeight.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 53,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 28, right: 28),
                  margin: EdgeInsets.fromLTRB(0, 12, 0, 18),
                  decoration: BoxDecoration(
                      color: blackColor,
                      borderRadius: BorderRadius.circular(4)),
                ),
                Form(
                  key: controller.globalKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: TextAndStyle(
                          title: currentLanguage['lbl_firstName'],
                          color: blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextFormFieldWidget(
                        textInputAction: TextInputAction.next,
                        controller: controller.firstNameController,
                        hintText: currentLanguage['lbl_firstName'],
                        filledColor: whiteColor,
                        cursorColor: blackColor,
                        focusBorder: BorderSide(
                          color: bordergrey,
                        ),
                        border: BorderSide(
                          color: bordergrey,
                        ),
                        enabledBorder: BorderSide(
                          color: bordergrey,
                        ),
                        style: TextStyle(color: black15),
                        hintStyle: TextStyle(color: black15),
                        validator: (value) => Validators.validateText(
                          value: value!.trim(),
                          maxLen: 50,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.saveBtnClick();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          margin: EdgeInsets.only(top: 20, bottom: 30),
                          decoration: BoxDecoration(
                            color: appColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextAndStyle(
                            title: currentLanguage['btn_save'],
                            letterSpacing: 0.2,
                            color: whiteColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
