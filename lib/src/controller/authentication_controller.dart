import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/models/login_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/models/chapter_model.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/common_method.dart';
import 'package:drive/src/models/questions_model.dart';
import 'package:drive/src/modules/exam/exam_date.dart';
import 'package:drive/src/utils/process_indicator.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/modules/login/signin_screen.dart';
import 'package:drive/src/utils/network_dio/network_dio.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as appleSingnIn;

RxBool isWantRegistration = false.obs;
RxBool registration = false.obs;
RxBool isSignIn = true.obs;

class AuthenticationController extends GetxController {
  final CommonMethod commonMethod = locator<CommonMethod>();
  final GlobalSingleton globalSingleton = locator<GlobalSingleton>();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  final NetworkDioHttp _networkDioHttp = locator<NetworkDioHttp>();
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();
  final GlobalKey<FormState> nameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> credentialsKey = GlobalKey<FormState>();
  final LanguageController languageController = Get.put(LanguageController());
  TextEditingController firstNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  ChapterModel chapterModel = ChapterModel();
  QuestionsModel questionsModel = QuestionsModel();
  GetStorage getStorage = GetStorage();
  Circle progressIndicator = Circle();
  signUpWithEmail(context) async {
    if (credentialsKey.currentState!.validate()) {
      Map signUpData = {
        "deviceToken": globalSingleton.deviceToken,
        "email": emailController.text.toString(),
        "deviceType": CommonMethod().getPlatform(),
        "password": passwordController.text.toString(),
        "firstName": firstNameController.text.toString(),
      };
      LoginModel? signUpResponse =
          await _networkRepository.userRegistration(context, signUpData);
      if (signUpResponse != null) {
        if (signUpResponse.statusCode == 200) {
          isWantRegistration = false.obs;
          isSignIn = true.obs;
          registration.value = false;
          await setPreferenceDataFromModel(signUpResponse, context);
        } else {
          ErrorDialog.showErrorDialog(
            currentLanguage['loginFailed_text'],
            title: currentLanguage['loginFailed_title'],
          );
        }
      }
    }
  }

  signInWithEmail(context) async {
    if (credentialsKey.currentState!.validate()) {
      Map signInData = {
        "deviceToken": globalSingleton.deviceToken,
        "email": emailController.text.toString(),
        "deviceType": CommonMethod().getPlatform(),
        "password": passwordController.text.toString(),
      };
      LoginModel? signInResponse =
          await _networkRepository.userLogin(context, signInData);
      if (signInResponse != null) {
        if (signInResponse.statusCode == 200) {
          isWantRegistration = false.obs;
          isSignIn = true.obs;
          registration.value = false;
          await setPreferenceDataFromModel(signInResponse, context);
        } else {
          ErrorDialog.showErrorDialog(
            currentLanguage['loginFailed_text'],
            title: currentLanguage['loginFailed_title'],
          );
        }
      }
    }
  }

  nextButton() {
    if (nameKey.currentState!.validate()) {
      isWantRegistration.value = false;
      isSignIn.value = false;
      registration.value = true;
    }
    update();
  }

  Future<Null> facebookLogin(context) async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email'],
      loginBehavior: LoginBehavior.webOnly,
    );

    switch (result.status) {
      case LoginStatus.success:
        final accessToken = await FacebookAuth.instance.accessToken;
        final token = accessToken;
        Map authUserData = {
          "deviceToken": globalSingleton.deviceToken.toString(),
          "deviceType": CommonMethod().getPlatform(),
          "accessToken": token!.token,
        };
        LoginModel? authResponse;
        authResponse =
            await _networkRepository.userFacebookLogin(context, authUserData);

        if (authResponse != null) {
          if (authResponse.statusCode == 200) {
            await setPreferenceDataFromModel(authResponse, context);
          } else {
            ErrorDialog.showErrorDialog(
                authResponse.message ?? 'Something went wrong');
          }
        }
        break;
      case LoginStatus.cancelled:
        break;
      case LoginStatus.failed:
        break;
      case LoginStatus.operationInProgress:
        print('Facebook login in progress...!');
        break;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future<void> googleLogin(context) async {
    _googleSignIn.disconnect();

    try {
      _googleSignIn.signIn().then(
        (GoogleSignInAccount? acc) async {
          if (acc != null)
            acc.authentication.then(
              (GoogleSignInAuthentication auth) async {
                Map googleAuthData = {
                  "displayName": acc.displayName,
                  "email": acc.email,
                  "photoUrl": acc.photoUrl,
                  "accessToken": auth.accessToken,
                  "idToken": auth.idToken,
                };
                Map authUserData = {
                  "deviceToken": globalSingleton.deviceToken.toString(),
                  "deviceType": CommonMethod().getPlatform(),
                  "accessToken": googleAuthData['accessToken'],
                  "idToken": googleAuthData['idToken']
                };
                LoginModel? authResponse;
                authResponse = await _networkRepository.userGmailLogin(
                    context, authUserData);

                if (authResponse != null) {
                  if (authResponse.statusCode == 200) {
                    await setPreferenceDataFromModel(authResponse, context);
                  } else {
                    ErrorDialog.showErrorDialog(
                        authResponse.message ?? 'Something went wrong');
                  }
                }
              },
            );
        },
      );
    } catch (e) {
      print("++++ google login error: $e");
    }
  }

  Future<void> handleAppleSignIn(context) async {
    try {
      if (await appleSingnIn.TheAppleSignIn.isAvailable()) {
        final appleSingnIn.AuthorizationResult result =
            await appleSingnIn.TheAppleSignIn.performRequests([
          appleSingnIn.AppleIdRequest(requestedScopes: [
            appleSingnIn.Scope.email,
            appleSingnIn.Scope.fullName
          ])
        ]);
        switch (result.status) {
          case appleSingnIn.AuthorizationStatus.authorized:
            dynamic authData = {
              "deviceToken": globalSingleton.deviceToken.toString(),
              "identityToken": result.credential!.identityToken,
              "deviceType": CommonMethod().getPlatform(),
              "familyName": result.credential!.fullName!.familyName.toString(),
              "givenName": result.credential!.fullName!.givenName.toString(),
            };
            // print("DEVICE TOKEN Apple: ${authData['deviceToken']}");
            await appleLogin(context, authData);
            break;
          case appleSingnIn.AuthorizationStatus.cancelled:
            print('User cancelled');
            break;
          case appleSingnIn.AuthorizationStatus.error:
            print("Sign in failed: ${result.error!.localizedDescription}");
            break;
        }
      }
    } catch (e) {
      print("++++ Apple login error: $e");
    }
  }

  appleLogin(context, dynamic appleAuthData) async {
    LoginModel? authResponse;
    authResponse =
        await _networkRepository.userAppleLogin(context, appleAuthData);

    if (authResponse != null) {
      if (authResponse.statusCode == 200) {
        setPreferenceDataFromModel(authResponse, context);
      } else {
        ErrorDialog.showErrorDialog(
            authResponse.message ?? 'Something went wrong');
      }
    }
  }

  setPreferenceDataFromModel(
      LoginModel authResponse, BuildContext context) async {
    GetStorage getStorage = GetStorage();
    if (authResponse.data!.user!.expiresSubscription != null) {
      DateTime expiresSubscription =
          DateTime.parse(authResponse.data!.user!.expiresSubscription!).toUtc();
      DateTime now = DateTime.now().toUtc();
      Duration duration = now.difference(expiresSubscription);
      if (duration.inHours.isNegative) {
        getStorage.write('isSubscribe', true);
      } else {
        getStorage.write('isSubscribe', false);
      }
    } else {
      getStorage.write('isSubscribe', false);
    }
    getStorage.write('token', authResponse.data!.token.toString());
    getStorage.write(
        'refreshToken', authResponse.data!.refreshToken.toString());
    getStorage.write('userName', authResponse.data!.user!.username.toString());
    getStorage.write(
        'phoneNumber', authResponse.data!.user!.phoneNumber.toString());
    getStorage.write('userId', authResponse.data!.user!.id.toString());
    getStorage.write('uid', authResponse.data!.user!.uid.toString());
    getStorage.write('email', authResponse.data!.user!.email.toString());
    getStorage.write(
        'firstName', authResponse.data!.user!.firstName.toString());
    getStorage.write('photoUrl', authResponse.data!.user!.photoUrl.toString());

    getStorage.write(
        'learnReminderEnabled', authResponse.data!.user!.learnReminderEnabled);
    getStorage.write('isLoggedIn', true);

    await _networkDioHttp.setDynamicHeader(endPoint: _appConstants.apiEndPoint);
    String? authToken = getStorage.read('token');
    firstNameController.clear();
    emailController.clear();
    passwordController.clear();
    update();
    if (authToken != null && authToken != "") {
      Get.offAll(() => ExamDateScreen(
            isformLogin: true,
          ));
    } else {
      Get.offAll(
        () => SigninScreen(),
        binding: AuthenticationBinding(),
      );
    }
  }
}
