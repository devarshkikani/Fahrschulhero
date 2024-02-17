import 'dart:developer';
import 'dart:io';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/models/login_model.dart';
import 'package:drive/src/modules/exam/exam_date.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/network_dio/network_dio.dart';
import 'package:drive/src/utils/validator.dart';
import 'package:drive/src/widgets/common_method.dart';
import 'package:drive/src/widgets/modal_sheet.dart';
import 'package:drive/src/widgets/text_widgets/input_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ignore: must_be_immutable
class ForgotPasswordScreen extends GetView {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  final NetworkDioHttp _networkDioHttp = locator<NetworkDioHttp>();
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();

  Rx<TextEditingController> emailController =
      Rx<TextEditingController>(TextEditingController());
  Rx<TextEditingController> otpController =
      Rx<TextEditingController>(TextEditingController());
  Rx<TextEditingController> newPasswordController =
      Rx<TextEditingController>(TextEditingController());
  Rx<TextEditingController> confirmController =
      Rx<TextEditingController>(TextEditingController());
  Rx<PageController> pageController = Rx<PageController>(PageController());
  GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  final GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  GetStorage _getStorage = GetStorage();
  RxInt pageIndex = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: blackColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              if (pageIndex.value == 0) {
                Get.back();
              } else if (pageIndex.value == 1) {
                pageController.value.jumpToPage(0);
              } else {
                pageController.value.jumpToPage(1);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(28, 28, 28, 10),
          child: PageView.builder(
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              controller: pageController.value,
              onPageChanged: (num) {
                pageIndex.value = num;
              },
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return index == 0
                    ? emailWidget(context: context)
                    : index == 1
                        ? otpWidget(context: context)
                        : passwordWidget(context: context);
              }),
        ),
        bottomNavigationBar: Obx(
          () => Container(
            height: 135,
            margin: EdgeInsets.fromLTRB(28, 28, 28, 28),
            child: Column(
              children: [
                pageIndex.value == 0
                    ? buttonDecoration(
                        title: currentLanguage['forgot_send'],
                        onTap: () async {
                          if (emailFormKey.currentState!.validate()) {
                            Map code = await _networkRepository.sendVerifyCode(
                                context, {'email': emailController.value.text});
                            if (code['statusCode'] == 200) {
                              pageController.value.jumpToPage(1);
                            }
                          }
                        },
                      )
                    : pageIndex.value == 1
                        ? buttonDecoration(
                            title: currentLanguage['forgot_verificationBtn'],
                            onTap: () {
                              if (otpFormKey.currentState!.validate()) {
                                pageController.value.jumpToPage(2);
                              }
                            },
                          )
                        : buttonDecoration(
                            title: currentLanguage['forgot_reset'],
                            onTap: () async {
                              if (passwordFormKey.currentState!.validate()) {
                                Map resetData = {
                                  "deviceToken": _globalSingleton.deviceToken,
                                  "deviceType": CommonMethod().getPlatform(),
                                  "email": emailController.value.text,
                                  "password": confirmController.value.text,
                                  "verificationCode": otpController.value.text,
                                };
                                dynamic response = await _networkRepository
                                    .resetPassword(context, resetData);
                                log(response.toString());
                                if (response['statusCode'] == 200 ||
                                    response['statusCode'] == "200") {
                                  LoginModel loginData = LoginModel.fromJson(
                                    response,
                                  );
                                  GetStorage getStorage = GetStorage();
                                  if (loginData
                                          .data!.user!.expiresSubscription !=
                                      null) {
                                    DateTime expiresSubscription =
                                        DateTime.parse(loginData.data!.user!
                                                .expiresSubscription!)
                                            .toUtc();
                                    DateTime now = DateTime.now().toUtc();
                                    Duration duration =
                                        now.difference(expiresSubscription);
                                    if (duration.inHours.isNegative) {
                                      getStorage.write('isSubscribe', true);
                                    } else {
                                      getStorage.write('isSubscribe', false);
                                    }
                                  } else {
                                    getStorage.write('isSubscribe', false);
                                  }
                                  getStorage.write('token',
                                      loginData.data!.token.toString());
                                  getStorage.write('refreshToken',
                                      loginData.data!.refreshToken.toString());
                                  getStorage.write(
                                      'userName',
                                      loginData.data!.user!.username
                                          .toString());
                                  getStorage.write(
                                      'phoneNumber',
                                      loginData.data!.user!.phoneNumber
                                          .toString());
                                  getStorage.write('userId',
                                      loginData.data!.user!.id.toString());
                                  getStorage.write('uid',
                                      loginData.data!.user!.uid.toString());
                                  getStorage.write('email',
                                      loginData.data!.user!.email.toString());
                                  getStorage.write(
                                      'firstName',
                                      loginData.data!.user!.firstName
                                          .toString());
                                  getStorage.write(
                                      'photoUrl',
                                      loginData.data!.user!.photoUrl
                                          .toString());

                                  getStorage.write(
                                      'learnReminderEnabled',
                                      loginData
                                          .data!.user!.learnReminderEnabled);
                                  getStorage.write('isLoggedIn', true);
                                  await _networkDioHttp.setDynamicHeader(
                                      endPoint: _appConstants.apiEndPoint);
                                  String authToken =
                                      _getStorage.read('token') ?? '';

                                  if (authToken != "")
                                    Get.offAll(() => ExamDateScreen(
                                          isformLogin: true,
                                        ));
                                } else if (response['statusCode'] == 400 ||
                                    response['statusCode'] == "400") {
                                  ShowModalsheet.oneButtomModalSheet(
                                      height: 260,
                                      title: currentLanguage[
                                          'forgot_codeIncorrectTitle'],
                                      onOkPress: () {
                                        Get.back();
                                        pageController.value.jumpToPage(1);
                                      },
                                      description: currentLanguage[
                                          'forgot_codeIncorrect'],
                                      okbtnTitle: currentLanguage['global_ok']);
                                }
                              }
                            },
                          ),
              ],
            ),
          ),
        ));
  }

  Widget emailWidget({required BuildContext context}) {
    return Form(
      key: emailFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextAndStyle(
              title: currentLanguage['forgot_title'],
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
            SizedBox(
              height: 6,
            ),
            TextAndStyle(
              title: currentLanguage['forgot_subtitle'],
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: whiteColor,
            ),
            SizedBox(
              height: 29,
            ),
            EmailWidget(
              controller: emailController.value,
              borderSide: BorderSide(color: textGreyColor),
              hintText: "Email",
            ),
          ],
        ),
      ),
    );
  }

  Widget otpWidget({BuildContext? context}) {
    otpController = Rx<TextEditingController>(TextEditingController());
    return Form(
      key: otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextAndStyle(
            title: currentLanguage['forgot_verification'],
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
          SizedBox(
            height: 6,
          ),
          TextAndStyle(
            title: currentLanguage['forgot_verificationSubtitle'],
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: whiteColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: PinCodeTextField(
              appContext: context!,
              length: 4,
              blinkWhenObscuring: true,
              animationType: AnimationType.fade,
              validator: (value) => Validators.validateDigits(
                  value!, currentLanguage['forgot_codeRequired'], 4),
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(16),
                  borderWidth: 1.0,
                  fieldHeight: 47,
                  fieldWidth: 54,
                  activeColor: textGreyColor,
                  inactiveColor: textGreyColor,
                  selectedColor: textGreyColor,
                  activeFillColor: black15,
                  selectedFillColor: black15,
                  inactiveFillColor: black15),
              cursorColor: whiteColor,
              hintCharacter: '0',
              hintStyle: TextStyle(
                color: whiteColor.withOpacity(0.20),
                fontSize: 16,
              ),
              textStyle: TextStyle(
                color: whiteColor,
                fontSize: 16,
              ),
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              controller: otpController.value,
              keyboardType: TextInputType.number,
              onCompleted: (v) {},
              onChanged: (value) {},
            ),
          ),
          GestureDetector(
            onTap: () async {
              Map code = await _networkRepository.sendVerifyCode(
                  context, {'email': emailController.value.text});
              if (code['statusCode'] == 200) {
                Get.snackbar(
                    currentLanguage['forgot_sentTitle'],
                    currentLanguage['forgot_sentText']
                        .toString()
                        .replaceAll('{0}', emailController.value.text),
                    colorText: whiteColor,
                    backgroundColor: black15,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: TextAndStyle(
              title: currentLanguage['forgot_resend'],
              color: appColor,
              fontSize: 15,
              textDecoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordWidget({required BuildContext context}) {
    return Form(
      key: passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextAndStyle(
            title: currentLanguage['forgot_resetTitle'],
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
          SizedBox(
            height: 6,
          ),
          TextAndStyle(
            title: currentLanguage['forgot_resetSubtitle'],
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: whiteColor,
          ),
          SizedBox(
            height: 29,
          ),
          PasswordWidget(
            controller: newPasswordController.value,
            hintText: currentLanguage['forgot_newPassword'],
            showsuffixIcon: false,
            borderSide: BorderSide(color: textGreyColor),
          ),
          SizedBox(
            height: 12,
          ),
          PasswordWidget(
            controller: confirmController.value,
            hintText: currentLanguage['forgot_passwordConfirm'],
            showsuffixIcon: true,
            borderSide: BorderSide(color: textGreyColor),
            validator: (value) =>
                Validators.validatePassword(value!.trim()) ??
                (value != newPasswordController.value.text
                    ? currentLanguage['forgot_passNotMatch']
                    : null),
          ),
        ],
      ),
    );
  }

  Widget buttonDecoration(
      {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: Get.width,
        decoration: BoxDecoration(
          color: appColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: TextAndStyle(
            title: title,
            color: whiteColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
