import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:drive/src/style/colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/modules/login/signin_screen.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drive/src/widgets/common_method.dart';
import 'package:drive/src/widgets/common_widget.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SettingScreenController extends GetxController {
  final languageController = Get.put(LanguageController());
  final CommonWidget commonWidget = locator<CommonWidget>();
  final CommonMethod commonMethod = locator<CommonMethod>();
  final GlobalSingleton globalSingleton = locator<GlobalSingleton>();
  final NetworkRepository networkRepository = locator<NetworkRepository>();
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  RxString firstName = ''.obs;
  RxBool isSubscribe = (GetStorage().read('isSubscribe') == true).obs;
  DatabaseHelper databaseHelper = DatabaseHelper();
  GetStorage getStorage = GetStorage();
  RxString selectedImagePath = ''.obs, base64Image = ''.obs;
  final picker = ImagePicker();
  RxString appVersionAndEnvironment = ''.obs;
  RxBool reminder = true.obs;
  RxDouble modalSheetHeight = 230.0.obs;
  RxBool dateTimeValue =
      (GetStorage().read('useNewQuestionsVersion') == true).obs;
  RxString versionDate = ''.obs;
  DateTime? dateTime;

  @override
  void onInit() {
    super.onInit();
    reminder.value = getStorage.read('learnReminderEnabled') ?? true;
    getAppVersionAndEnvironment();
    callAPI();
    firstName.value = getStorage.read('firstName') ?? '';
  }

  void getAppVersionAndEnvironment() async {
    if (isInternetOn.value) {
      Map? response = await networkRepository.getAppVersionAndEnvironment(null);
      if (response != null && response['statusCode'] == 200) {
        appVersionAndEnvironment.value = response['message'];
        getStorage.write(
            'appVersionAndEnvironment', appVersionAndEnvironment.value);
      }
    } else {
      appVersionAndEnvironment.value =
          getStorage.read('appVersionAndEnvironment') ?? '';
    }
  }

  void callAPI() async {
    Map response = await networkRepository.getVersionChangeDate(null);
    if (response['statusCode'] == 200) {
      dateTime = DateTime.parse(response['data']);
      versionDate.value =
          '${dateTime!.day}.${dateTime!.month}.${dateTime!.year}';
    }
  }

  void signOut(context) async {
    String deviceToken = globalSingleton.deviceToken.toString();
    final language = getStorage.read('language');
    final translation = getStorage.read('translation');
    final translationVersion = getStorage.read('translationVersion');
    final questionVersion = getStorage.read('questionVersion');
    bool isReviewdApp = getStorage.read('isReviewdApp') ?? false;
    final response = await networkRepository
        .userSignOut(context, {'deviceToken': deviceToken});
    if (response != null) {
      if (response['statusCode'] == 200) {
        await getStorage.erase();
        await databaseHelper.deleteTable();
        final GoogleSignIn _googleSignIn = GoogleSignIn(
          scopes: <String>[
            'email',
          ],
        );
        await _googleSignIn.signOut();
        getStorage.write('language', language);
        getStorage.write('translation', translation);
        getStorage.write('questionVersion', questionVersion);
        getStorage.write('translationVersion', translationVersion);
        getStorage.write('isReviewdApp', isReviewdApp);
        getStorage.write('isLoggedIn', false);
        Get.find<HomeController>().timer?.cancel();
        Get.offAll(
          () => SigninScreen(),
          binding: AuthenticationBinding(),
        );
      } else {
        ErrorDialog.showErrorDialog(response.message ?? 'Something went wrong');
      }
    }
  }

  void deletAccount(context) {
    ShowModalsheet.twoButtomModalSheet(
      height: 300,
      title: currentLanguage['modal_deleteAccTitle'],
      description: currentLanguage['modal_deleteAccText'],
      okbtnTitle: currentLanguage['btn_delete'],
      cancelbtnTitle: currentLanguage['btn_cancel'],
      hightedColor: currentLanguage['modal_deleteAccSubscription'],
      onOkPress: () {
        closeAccount(context);
      },
      onCancelPress: () {
        Get.back();
      },
    );
  }

  closeAccount(context) async {
    final language = getStorage.read('language');
    final translation = getStorage.read('translation');
    final translationVersion = getStorage.read('translationVersion');
    final questionVersion = getStorage.read('questionVersion');
    bool isReviewdApp = getStorage.read('isReviewdApp') ?? false;

    final closeAccountData = await networkRepository.closeAccount(context);
    if (closeAccountData != null) {
      if (closeAccountData["statusCode"] == "200" ||
          closeAccountData["statusCode"] == 200) {
        await databaseHelper.deleteTable();
        getStorage.remove('token');
        await getStorage.erase();
        getStorage.write('isLoggedIn', false);
        getStorage.write('language', language);
        getStorage.write('translation', translation);
        getStorage.write('translationVersion', translationVersion);
        getStorage.write('questionVersion', questionVersion);
        getStorage.write('isReviewdApp', isReviewdApp);
        Get.find<HomeController>().timer?.cancel();
        Get.to(
          () => SigninScreen(),
          binding: AuthenticationBinding(),
        );
      } else {
        ErrorDialog.showErrorDialog(
            closeAccountData['message'] ?? 'Something went wrong');
      }
    }
  }

  updateProfilePic(context) async {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: appColor,
                ),
                title: new Text('Camera'),
                onTap: () async {
                  PermissionStatus status = await Permission.camera.request();
                  print(status);
                  if (status == PermissionStatus.granted) {
                    getImageFromSource(ImageSource.camera, context);
                  } else if (status != PermissionStatus.denied &&
                      status != PermissionStatus.permanentlyDenied) {
                    getImageFromSource(ImageSource.camera, context);
                  } else {
                    showPermissionDialog(
                        currentLanguage['permission_cameraText']);
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: appColor,
                ),
                title: new Text('Gallery'),
                onTap: () {
                  getImageFromSource(ImageSource.gallery, context);
                },
              ),
              SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }

  void showPermissionDialog(String title) {
    ShowModalsheet.twoButtomModalSheet(
      height: 250,
      title: currentLanguage['permission_title'],
      description: title,
      okbtnTitle: currentLanguage['btn_settings'],
      cancelbtnTitle: currentLanguage['btn_deny'],
      onOkPress: () {
        openAppSettings();
      },
      onCancelPress: () {
        Get.back();
      },
    );
  }

  Future<void> getImageFromSource(ImageSource source, context) async {
    final image = await picker.pickImage(source: source);
    if (image == null) {
      Get.back();
      return;
    }
    File? croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (croppedImage != null) {
      selectedImagePath.value = croppedImage.path;
    }
    final bytes = File(selectedImagePath.value).readAsBytesSync();
    base64Image.value = base64Encode(bytes);
    Map updateUserData = {"photoBase64": base64Image.value};
    Map updatedData =
        await networkRepository.updateUser(context, updateUserData);
    if (updatedData['statusCode'] == 200 ||
        updatedData['statusCode'] == '200') {
      getStorage.write('photoUrl', updatedData['data']['photoUrl']);
      Get.back();
    }
  }

  Future<void> switchChange() async {
    reminder.value = !reminder.value;
    Map updateUserData = {'learnReminderEnabled': reminder.value};
    Map updatedData = await networkRepository.updateUser(null, updateUserData);
    if (updatedData['statusCode'] == 200 ||
        updatedData['statusCode'] == '200') {
      getStorage.write('learnReminderEnabled', reminder.value);
    }
  }

  Future<void> dateTimeValueChange() async {
    dateTimeValue.value = !dateTimeValue.value;
    Map updateUserData = {'useNewQuestionsVersion': dateTimeValue.value};
    Map updatedData = await networkRepository.updateUser(null, updateUserData);
    if (updatedData['statusCode'] == 200 ||
        updatedData['statusCode'] == '200') {
      getStorage.write('useNewQuestionsVersion', dateTimeValue.value);
    }
  }

  Future<void> saveBtnClick() async {
    if (globalKey.currentState!.validate()) {
      modalSheetHeight.value = 230;
      firstName.value = firstNameController.text;
      Map updateUserData = {
        'firstName': firstName.value,
      };
      Map updatedData =
          await networkRepository.updateUser(null, updateUserData);
      if (updatedData['statusCode'] == 200 ||
          updatedData['statusCode'] == '200') {
        getStorage.write('firstName', firstName.value);
        Get.back();
      }
    } else {
      modalSheetHeight.value = 255;
    }
  }
}
