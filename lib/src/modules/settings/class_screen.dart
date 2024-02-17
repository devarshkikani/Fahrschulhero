// ignore_for_file: must_be_immutable
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
// import 'package:drive/src/widgets/change_language.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drive/main_home_screen.dart';
import 'package:drive/src/binding/main_home_screen_binding.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/models/chapter_model.dart';
import 'package:drive/src/models/questions_model.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/process_indicator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:get_storage/get_storage.dart';

import '../../controller/main_home_controller.dart';

class ClassScreen extends StatefulWidget {
  bool isformLogin;
  ClassScreen({required this.isformLogin});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  NetworkRepository networkRepository = locator<NetworkRepository>();
  final languageController = Get.put(LanguageController());
  DatabaseHelper databaseHelper = DatabaseHelper();
  ChapterModel chapterModel = ChapterModel();
  RxList allClassData = [].obs;
  GetStorage getStorage = GetStorage();
  QuestionsModel questionsModel = QuestionsModel();
  Circle progressIndicator = Circle();
  RxString selectedId = ''.obs;

  @override
  void initState() {
    super.initState();
    getAllClass(context);
    selectedId.value = getStorage.read('classId') ?? '';
  }

  setClass(index) {
    selectedId.value = allClassData[index]['id'];
  }

  continueOnTap(context, bool isFromLogin) async {
    Map updateUserData = {"classId": selectedId.value};
    Map updatedData =
        await networkRepository.updateUser(context, updateUserData);
    if (updatedData['statusCode'] == 200 ||
        updatedData['statusCode'] == '200') {
      await getAllQuestions(context, isFromLogin);
    }
  }

  getAllClass(context) async {
    Map getallClassData = await networkRepository.getAllClass(context);
    if (getallClassData['statusCode'] == 200 ||
        getallClassData['statusCode'] == '200') {
      allClassData.value = getallClassData['data'];
    } else {
      ErrorDialog.showErrorDialog(
          getallClassData['message'] ?? 'Something went wrong');
    }
  }

  getAllQuestions(context, bool isfromLogin) async {
    final response = await networkRepository.getAllQuestions(context);
    if (response != null) {
      if (response['statusCode'] == 200 || response['statusCode'] == '200') {
        getStorage.write('classId', selectedId.value);
        progressIndicator.show(context);
        if (isfromLogin != true) {
          await databaseHelper.deleteTable();
        }
        await databaseHelper.onCreate();
        await databaseHelper.insertChapter(response);
        progressIndicator.hide(context);
        pageIndex.value = 0;
        if (isfromLogin) {
          await Get.offAll(() => MainHomeScreen(), binding: MainHomeBinding());
        } else {
          Get.offAll(() => MainHomeScreen(), binding: MainHomeBinding());
        }
      } else {
        if (progressIndicator.isShow) progressIndicator.hide(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        appBar: widget.isformLogin
            ? PreferredSize(child: SizedBox(), preferredSize: Size.zero)
            : AppBar(
                backgroundColor: appBackgroundColor,
                elevation: 0.0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryBlack,
                      size: 20.0,
                    ),
                  ),
                ),
                // actions: [
                //   ChangeLanguage(),
                //   SizedBox(
                //     width: 28,
                //   ),
                // ],
              ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: widget.isformLogin ? 11 : 0,
                    ),
                    Obx(
                      () => TextAndStyle(
                        title: currentLanguage['modal_chooseCourse'],
                        color: tabBarText,
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(
                      height: widget.isformLogin ? 0 : 6,
                    ),
                    widget.isformLogin
                        ? SizedBox()
                        : Obx(
                            () => TextAndStyle(
                              title:
                                  currentLanguage['modal_chooseCourseSubtitle'],
                              color: tabBarText,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                    SizedBox(
                      height: 6,
                    ),
                    Obx(
                      () => ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 11),
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allClassData.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setClass(index);
                              },
                              child: Obx(
                                () => Container(
                                  padding: EdgeInsets.all(15),
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: selectedId.value !=
                                            allClassData[index]['id']
                                        ? primaryWhite
                                        : appColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: TextAndStyle(
                                              title:
                                                  'Klasse ${allClassData[index]['id']} - ${allClassData[index]['name']}',
                                              color: selectedId.value !=
                                                      allClassData[index]['id']
                                                  ? primaryBlack
                                                  : whiteColor,
                                              fontSize: 14.0,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              maxLine: 3,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      selectedId.value !=
                                              allClassData[index]['id']
                                          ? Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                color: checkBoxColor,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            )
                                          : Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: 16,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => selectedId.value != '' && allClassData.isNotEmpty
                ? Positioned(
                    bottom: 0.0,
                    child: Container(
                      height: 100,
                      width: Get.width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: new LinearGradient(
                          colors: [primaryWhite.withOpacity(0.0), primaryWhite],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          continueOnTap(context, widget.isformLogin);
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(90, 20, 90, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: appColor,
                          ),
                          child: TextAndStyle(
                              title: currentLanguage['btn_confirm'],
                              fontFamily: "Rubik",
                              letterSpacing: 0.2,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: primaryWhite),
                        ),
                      ),
                    ),
                  )
                : SizedBox()),
          ],
        ),
      ),
    );
  }
}
