import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/widgets/buttons/elevated_button.dart';
import 'package:drive/src/widgets/buttons/outline_button.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ShowModalsheet {
  static void twoButtomModalSheet({
    required double height,
    required String title,
    required String description,
    required VoidCallback onOkPress,
    String? okbtnTitle,
    String? cancelbtnTitle,
    String? hightedColor,
    VoidCallback? onCancelPress,
  }) {
    Get.bottomSheet(
      Container(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 53,
                  padding: EdgeInsets.only(left: 28, right: 28),
                  margin: EdgeInsets.fromLTRB(0, 12, 0, 18),
                  decoration: BoxDecoration(
                      color: blackColor,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 14),
                child: TextAndStyle(
                  title: title,
                  color: blackColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextAndStyle(
                title: description,
                color: blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
              ),
              if (hightedColor != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextAndStyle(
                    title: hightedColor,
                    color: blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlineButtonWidget(
                      onPressed: onCancelPress ??
                          () {
                            Get.back();
                          },
                      title: cancelbtnTitle ?? currentLanguage['btn_cancel'],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SecondaryButton(
                      onPressed: onOkPress,
                      title: okbtnTitle ?? 'Confirm',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      backgroundColor: whiteColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    );
  }

  static void oneButtomModalSheet(
      {required double height,
      required String title,
      required String description,
      required VoidCallback onOkPress,
      required String okbtnTitle,
      bool barrierDismissible = false,
      Widget? icon}) {
    Get.bottomSheet(
      WillPopScope(
        onWillPop: () async {
          return barrierDismissible;
        },
        child: Container(
          height: height,
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
                icon ?? SizedBox(),
                Padding(
                  padding:
                      EdgeInsets.only(top: icon == null ? 20 : 18, bottom: 14),
                  child: TextAndStyle(
                    title: title,
                    color: blackColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextAndStyle(
                  title: description,
                  color: blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.center,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 25),
                  width: 250,
                  child: SecondaryButton(
                    onPressed: onOkPress,
                    title: okbtnTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: barrierDismissible,
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
}
