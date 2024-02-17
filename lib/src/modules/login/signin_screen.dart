import 'dart:io';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/controller/authentication_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/login/signup_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/validator.dart';
import 'package:drive/src/widgets/text_widgets/input_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'forgot_password/forgot_password.dart';

class SigninScreen extends GetView<AuthenticationController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Get.offAll(() => SignupScreen(),
                  binding: AuthenticationBinding());
            },
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: whiteColor,
            ),
          ),
          backgroundColor: blackColor,
          elevation: 0.0,
        ),
        body: Container(
          height: Get.height,
          width: Get.width,
          padding: EdgeInsets.fromLTRB(28, 0, 28, 0),
          color: blackColor,
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.05,
                ),
                TextAndStyle(
                  title: currentLanguage['login_title'],
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  color: whiteColor,
                ),
                SizedBox(
                  height: 6,
                ),
                TextAndStyle(
                  title: currentLanguage['login_subtitle'],
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: whiteColor,
                ),
                SizedBox(
                  height: 29,
                ),
                Obx(
                  () => isWantRegistration.value
                      ? Form(
                          key: controller.nameKey,
                          child: Column(
                            children: [
                              TextFormFieldWidget(
                                textInputAction: TextInputAction.next,
                                controller: controller.firstNameController,
                                hintText: currentLanguage['lbl_firstName'],
                                filledColor: black15,
                                style: TextStyle(color: whiteColor),
                                focusBorder: BorderSide(color: textGreyColor),
                                border: BorderSide(color: textGreyColor),
                                enabledBorder: BorderSide(color: textGreyColor),
                                hintStyle: TextStyle(color: whiteColor),
                                validator: (value) => Validators.validateText(
                                  value: value!.trim(),
                                  text: currentLanguage['lbl_firstName'],
                                  maxLen: 50,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Obx(
                                () => socialMedia(
                                  icon: SizedBox(
                                    width: 25,
                                  ),
                                  text: currentLanguage['btn_next'],
                                  containerColor: whiteColor,
                                  textColor: blackColor,
                                  onTap: () {
                                    controller.nextButton();
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Form(
                          key: controller.credentialsKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              EmailWidget(
                                hintText: currentLanguage['global_email'],
                                controller: controller.emailController,
                                borderSide: BorderSide(color: textGreyColor),
                                validator: isSignIn.value && !registration.value
                                    ? (value) => Validators.validateLoginEmail(
                                        value!.trim())
                                    : (value) =>
                                        Validators.validateEmail(value!.trim()),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              PasswordWidget(
                                hintText: currentLanguage['global_password'],
                                controller: controller.passwordController,
                                borderSide: BorderSide(color: textGreyColor),
                                showsuffixIcon: true,
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              if (isSignIn.value)
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => ForgotPasswordScreen());
                                  },
                                  child: TextAndStyle(
                                    title:
                                        currentLanguage['login_forgotPassword'],
                                    color: appColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              SizedBox(
                                height: 16,
                              ),
                              socialMedia(
                                text: isSignIn.value && !registration.value
                                    ? currentLanguage['login_btn']
                                    : currentLanguage['login_register'],
                                containerColor: whiteColor,
                                textColor: blackColor,
                                onTap: () {
                                  if (isSignIn.value) {
                                    controller.signInWithEmail(context);
                                  } else {
                                    controller.signUpWithEmail(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextAndStyle(
                          title: isWantRegistration.value || registration.value
                              ? currentLanguage['register_alreadyAccount']
                              : currentLanguage['login_needAccount'],
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: whiteColor,
                        ),
                        GestureDetector(
                          child: TextAndStyle(
                            title:
                                isWantRegistration.value || registration.value
                                    ? ' ' + currentLanguage['login_login']
                                    : ' ' + currentLanguage['login_register'],
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            color: googlebackgroundColor,
                          ),
                          onTap: () {
                            if (isWantRegistration.value ||
                                registration.value) {
                              isWantRegistration.value = false;
                              isSignIn.value = true;
                              registration.value = false;
                            } else {
                              registration.value = true;
                              Get.offAll(
                                () => SignupScreen(),
                                binding: AuthenticationBinding(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Center(
                  child: TextAndStyle(
                    title: currentLanguage['login_continueWith'],
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: whiteColor,
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                if (Platform.isIOS)
                  socialMedia(
                    icon: Icon(
                      FontAwesomeIcons.apple,
                      size: 25,
                      color: blackColor,
                    ),
                    text: currentLanguage['login_apple'],
                    containerColor: whiteColor,
                    textColor: blackColor,
                    onTap: () {
                      controller.handleAppleSignIn(context);
                    },
                  ),
                socialMedia(
                    icon: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/google_logo.jpg"),
                        ),
                      ),
                    ),
                    text: currentLanguage['login_google'],
                    containerColor: googlebackgroundColor,
                    textColor: whiteColor,
                    onTap: () {
                      controller.googleLogin(context);
                    }),
                socialMedia(
                  icon: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/facebook_logo.png"),
                      ),
                    ),
                  ),
                  text: currentLanguage['login_facebook'],
                  containerColor: facebookLogoColor,
                  textColor: whiteColor,
                  onTap: () {
                    controller.facebookLogin(context);
                  },
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget socialMedia({
  Widget? icon,
  required String text,
  required Color containerColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 56,
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
          color: containerColor, borderRadius: BorderRadius.circular(16.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon != null
              ? Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: icon,
                )
              : SizedBox(),
          TextAndStyle(
              title: text,
              textAlign: TextAlign.center,
              fontSize: 16,
              color: textColor),
          SizedBox(
            width: icon != null ? 43 : 0,
          ),
        ],
      ),
    ),
  );
}
