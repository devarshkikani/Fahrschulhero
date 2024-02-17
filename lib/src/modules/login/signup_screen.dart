import 'dart:io';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/controller/authentication_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/login/signin_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends GetView<AuthenticationController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Colors.transparent, blackColor.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/login_image.jpg"),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextAndStyle(
                  title: currentLanguage['register_title'],
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                  color: whiteColor,
                ),
                SizedBox(
                  height: 6,
                ),
                TextAndStyle(
                  title: currentLanguage['register_subtitle'],
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: whiteColor,
                ),
                if (Platform.isIOS)
                  socialMedia(
                    icon: Icon(
                      FontAwesomeIcons.apple,
                      size: 25,
                      color: whiteColor,
                    ),
                    text: currentLanguage['continue_apple'],
                    containerColor: blackColor,
                    textColor: whiteColor,
                    onTap: () {
                      controller.handleAppleSignIn(context);
                    },
                  ),
                Obx(
                  () => socialMedia(
                    icon: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/google_logo.jpg"),
                        ),
                      ),
                    ),
                    text: currentLanguage['continue_google'],
                    containerColor: googlebackgroundColor,
                    textColor: whiteColor,
                    onTap: () {
                      controller.googleLogin(context);
                    },
                  ),
                ),
                Obx(
                  () => socialMedia(
                    icon: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/facebook_logo.png"),
                        ),
                      ),
                    ),
                    text: currentLanguage['continue_facebook'],
                    containerColor: facebookLogoColor,
                    textColor: whiteColor,
                    onTap: () {
                      controller.facebookLogin(context);
                    },
                  ),
                ),
                Obx(
                  () => socialMedia(
                    icon: Icon(
                      FontAwesomeIcons.solidEnvelope,
                      size: 25,
                      color: blueColor,
                    ),
                    text: currentLanguage['continue_email'],
                    containerColor: whiteColor,
                    textColor: blackColor,
                    onTap: () {
                      isWantRegistration.value = true;
                      isSignIn.value = false;
                      registration.value = true;
                      Get.offAll(
                        () => SigninScreen(),
                        binding: AuthenticationBinding(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Column(
                      children: [
                        TextAndStyle(
                          title: currentLanguage['register_agreeTerms'],
                          textAlign: TextAlign.center,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: whiteColor,
                        ),
                        GestureDetector(
                          onTap: () {
                            launch('https://www.afk-international.de/agb/');
                          },
                          child: Text(
                            currentLanguage['register_terms'],
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color: googlebackgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextAndStyle(
                        title: currentLanguage['register_alreadyAccount'],
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: whiteColor,
                      ),
                      InkWell(
                        child: TextAndStyle(
                          title: ' ' + currentLanguage['login_login'],
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: googlebackgroundColor,
                        ),
                        onTap: () {
                          isWantRegistration.value = false;
                          isSignIn.value = true;
                          registration.value = false;
                          Get.offAll(
                            () => SigninScreen(),
                            binding: AuthenticationBinding(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
