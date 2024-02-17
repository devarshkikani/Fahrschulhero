import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorDialog {
  static void showErrorDialog(String message, {String? title}) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.all(13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  print(Get.overlayContext);
                  Navigator.of(Get.overlayContext!).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: greyColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: whiteColor,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 31, vertical: 20),
                  child: Column(
                    children: [
                      TextAndStyle(
                        title: title ?? "Error!",
                        color: blackColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextAndStyle(
                        title: message,
                        color: textGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar({
  required String title,
  required String message,
  Color? backgroundColor,
  Color? colorText,
  EdgeInsets? margin,
}) {
  Get.snackbar(
    title,
    message,
    colorText: colorText ?? whiteColor,
    backgroundColor: backgroundColor ?? appColor,
    margin: margin ?? EdgeInsets.all(10),
    snackPosition: SnackPosition.BOTTOM,
  );
}
