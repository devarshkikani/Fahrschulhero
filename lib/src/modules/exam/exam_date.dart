// ignore_for_file: must_be_immutable

import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/settings/class_screen.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ExamDateScreen extends StatefulWidget {
  bool isformLogin;
  ExamDateScreen({Key? key, required this.isformLogin}) : super(key: key);

  @override
  State<ExamDateScreen> createState() => _ExamDateScreenState();
}

class _ExamDateScreenState extends State<ExamDateScreen> {
  NetworkRepository networkRepository = locator<NetworkRepository>();
  RxString firstDate = ''.obs;
  RxString secondDate = ''.obs;

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  void callAPI() async {
    Map response = await networkRepository.getVersionChangeDate(context);
    if (response['statusCode'] == 200) {
      DateTime secondOne = DateTime.parse(response['data']);
      DateTime firstOne = secondOne.subtract(Duration(days: 1));
      firstDate.value =
          '${firstOne.day.toString().padLeft(2, '0')}.${firstOne.month.toString().padLeft(2, '0')}';
      secondDate.value =
          '${secondOne.day.toString().padLeft(2, '0')}.${secondOne.month.toString().padLeft(2, '0')}';
    }
  }

  void onSubmitDate(context, bool useNewQuestionsVersion) async {
    Map updateUserData = {"useNewQuestionsVersion": useNewQuestionsVersion};

    final updatedData =
        await networkRepository.updateUser(context, updateUserData);
    if (updatedData['statusCode'] == 200 ||
        updatedData['statusCode'] == '200') {
      GetStorage().write('useNewQuestionsVersion', useNewQuestionsVersion);
      Get.offAll(
        () => ClassScreen(isformLogin: widget.isformLogin),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: TextAndStyle(
          title: currentLanguage['examDate_Title'],
          color: whiteColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: appColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextAndStyle(
                  title: currentLanguage['examDate_Subtitle'],
                  color: blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 12,
                ),
                Obx(
                  () => setDateForExam('01.04 - ' + firstDate.value, false),
                ),
                SizedBox(
                  height: 20,
                ),
                Obx(
                  () => setDateForExam(secondDate.value + ' - 31.03', true),
                ),
              ],
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Get.offAll(
                    () => ClassScreen(isformLogin: widget.isformLogin),
                  );
                },
                child: Container(
                    height: 56,
                    width: 256,
                    margin: EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(color: appColor),
                    ),
                    child: Obx(
                      () => TextAndStyle(
                        title: currentLanguage['examDate_noAnswer'],
                        color: whiteColor,
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget setDateForExam(String date, bool useNewQuestionsVersion) {
    return GestureDetector(
      onTap: () {
        onSubmitDate(context, useNewQuestionsVersion);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: whiteColor, borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextAndStyle(
              title: currentLanguage['lbl_between'],
              color: appColor,
              fontSize: 14,
            ),
            Spacer(),
            TextAndStyle(
              title: date,
              color: blackColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            SizedBox(
              width: 16,
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 16,
              color: appColor,
            ),
          ],
        ),
      ),
    );
  }
}
