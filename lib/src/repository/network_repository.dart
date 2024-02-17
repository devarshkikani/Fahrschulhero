import 'dart:convert';

import 'package:drive/app.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/models/login_model.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/network_dio/network_dio.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class NetworkRepository {
  static NetworkRepository _networkRepository = NetworkRepository._internal();
  final ApiEndpoints _apiEndpoints = locator<ApiEndpoints>();
  final NetworkDioHttp _networkDioHttp = locator<NetworkDioHttp>();
  GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  GetStorage _getStorage = GetStorage();
  factory NetworkRepository() {
    return _networkRepository;
  }
  NetworkRepository._internal();

  //sign up
  userRegistration(context, signUpData) async {
    try {
      final registrationResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.register}',
        data: signUpData,
      );
      return checkModelResponse(registrationResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //sign in
  userLogin(context, authUserData) async {
    try {
      final authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.login}',
        data: authUserData,
      );
      return checkModelResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //sign out
  userSignOut(context, deviceToken) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.signOut}',
        data: deviceToken,
      );
      return checkResponse(response, context);
    } catch (e) {
      return null;
    }
  }

  //google login
  userGmailLogin(context, authUserData) async {
    try {
      final authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.gmailAuth}',
        data: authUserData,
      );
      return checkModelResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Facebook Auth
  userFacebookLogin(context, authUserData) async {
    try {
      final authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.facebookAuth}',
        data: authUserData,
      );
      LoginModel response = checkModelResponse(authUserResponse, context);
      return response;
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //apple login
  userAppleLogin(context, authUserData) async {
    try {
      Map authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.appleAuth}',
        data: authUserData,
      );
      return checkModelResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //all questions
  getAllQuestions(context) async {
    try {
      Map authUserResponse = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getAllQuestion}',
      );
      return checkResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //after user answer
  answer(context, answerData) async {
    try {
      offlineAnswered.add(answerData);
      _getStorage.write('pendingAnsweredQuestions', offlineAnswered);
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.answer}',
        data: answerData,
      );
      if (response['error_description'] == null &&
          response['body']['statusCode'] == 200) {
        offlineAnswered.removeWhere(
            (element) => element['questionId'] == answerData['questionId']);
        _getStorage.write('pendingAnsweredQuestions', offlineAnswered);
      }
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // answerMultiple
  answerMultiple(context, answerData) async {
    try {
      Map authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.answerMultiple}',
        data: answerData,
      );
      return checkResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //after user answer in exam
  answerInExam(context, answerData) async {
    try {
      Map authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.answerInExam}',
        data: answerData,
      );
      return checkResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Exam Finish
  finish(context, examId) async {
    try {
      Map authUserResponse = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.finish}',
        data: examId,
      );
      return checkResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Get Class
  getAllClass(context) async {
    try {
      Map authUserResponse = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getAllClass}',
      );
      return checkResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Get Users Rank
  getUsersRank(context) async {
    try {
      Map userList = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getUsersRank}',
      );
      return checkResponse(userList, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Get Users Rank
  getCountdownMinutes(context) async {
    try {
      Map userList = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getCountdownMinutes}',
      );
      return checkResponse(userList, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // get user ranks OR points
  getAllRanks(context) async {
    try {
      Map userList = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getAllRanks}',
      );
      return checkResponse(userList, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // getUserRanksHistory
  getUserRanksHistory(context) async {
    try {
      Map userList = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getUserRanksHistory}',
      );
      return checkResponse(userList, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Contacts
  getFriends(context, data) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getFriends}',
        data: data,
      );
      return checkResponse(response, context);
    } catch (e) {}
  }

  saveContacts(context, contacts) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.saveContacts}',
        data: contacts,
      );
      return checkResponse(response, context);
    } catch (e) {}
  }

  getContacts(context, getContactsData) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getContacts}',
        data: getContactsData,
      );
      return checkResponse(response, context);
    } catch (e) {}
  }

  sendInvitation(context, indentifier) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.sendInvitation}',
        data: indentifier,
      );
      return checkResponse(response, context);
    } catch (e) {}
  }

  buyAppStore(context, purchaseDetails) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.buyAppStore}',
        data: purchaseDetails,
      );
      return checkResponse(response, context);
    } catch (e) {}
  }

  buyPlayStore(context, purchaseDetails) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.buyPlayStore}',
        data: purchaseDetails,
      );
      return checkResponse(response, context);
    } catch (e) {}
  }

  acceptJoinApp(invitationCode) async {
    final context = navigatorKey.currentState!.overlay!.context;
    try {
      Map readInvitationResponse = await _networkDioHttp.postDioHttpMethod(
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.acceptInvitation}',
        data: invitationCode,
        context: context,
      );
      return checkResponse(readInvitationResponse, context);
    } catch (e) {}
  }

  log(logMessage, {context, logLevel = 'Error'}) async {
    try {
      int userId = _getStorage.read('userId') ?? 0;
      await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.log}',
        data: {
          'logMessage': logMessage,
          'logLevel': logLevel,
          'userId': userId,
        },
      );
    } catch (e) {}
  }

  // getConfigurations
  getConfigurations(context) async {
    try {
      Map userList = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getConfigurations}',
      );
      return checkResponse(userList, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  getAppVersionAndEnvironment(context) async {
    try {
      Map userList = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url:
            '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getAppVersionAndEnvironment}',
      );
      return checkResponse(userList, context);
    } catch (e) {
      showErrorDialog('$e');
    }
  }

  //Translation
  Future<Map> getTranslations(context, language) async {
    try {
      Map response = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url:
            '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getTranslations}/$language',
      );
      final body = checkResponse(response, context) as Map;
      Map translations = body['data'];
      translations.forEach((key, value) {
        translations[key] = '${value.replaceAll('\\n', '\n')}';
      });
      return translations;
    } catch (e) {}
    return {};
  }

  getPricePerWeek(context) async {
    try {
      Map response = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getPricePerWeek}',
      );
      return checkResponse(response, context);
    } catch (e) {}
    return {};
  }

  getPricePerLife(context) async {
    try {
      Map response = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getPricePerLife}',
      );
      return checkResponse(response, context);
    } catch (e) {}
    return {};
  }

  //updateuser
  updateUser(context, updateUserData) async {
    try {
      Map authUserResponse = await _networkDioHttp.putDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.updateUser}',
        data: updateUserData,
      );
      return checkResponse(authUserResponse, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // isFavorite
  setFavorite(context, data) async {
    try {
      offlineIsFavorite.add(data);
      _getStorage.write('pendingIsFavorite', offlineIsFavorite);
      Map response = await _networkDioHttp.putDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.setFavorite}',
        data: data,
      );
      if (response['error_description'] == null &&
          response['body']['statusCode'] == 200) {
        offlineIsFavorite.removeWhere(
            (element) => element['questionId'] == data['questionId']);
        _getStorage.write('pendingIsFavorite', offlineIsFavorite);
      }
      return checkResponse(response, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // exam start
  examStart(context) async {
    try {
      final response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.startExam}',
        data: '',
      );
      return checkResponse(response, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Get Exam Result
  getExamResult(context, id) async {
    try {
      Map resultData = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getResult}/$id',
      );
      return checkResponse(resultData, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // Can user Do Exam
  canDoExam(context) async {
    try {
      Map resultData = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.canDoExam}',
      );
      return checkResponse(resultData, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  getVersionChangeDate(context) async {
    try {
      Map resultData = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url:
            '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getVersionChangeDate}',
      );
      return checkResponse(resultData, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  getUserDetails(context) async {
    try {
      Map resultData = await _networkDioHttp.getDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getUser}',
      );
      return checkResponse(resultData, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  // Get All School
  getSchool(schoolData, context) async {
    try {
      Map resultData = await _networkDioHttp.postDioHttpMethod(
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.getSchool}',
        data: schoolData,
      );
      return checkResponse(resultData, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  //Refresh
  Future<LoginModel?> getRefreshToken(tokenData) async {
    try {
      final response = await _networkDioHttp.postDioHttpMethod(
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.refreshToken}',
        data: tokenData,
      );
      LoginModel loginModel = checkModelResponse(response, null);
      return loginModel;
    } catch (e) {
      print('--------$e');
      return null;
    }
  }

  Future setTranslations({String? latestVersion}) async {
    if (latestVersion != null) {
      String? currentVersion = _getStorage.read('translationVersion');
      if (currentVersion != latestVersion) {
        bool isSuccess = await _refreshTranslations();
        if (isSuccess) {
          _getStorage.write('translationVersion', latestVersion);
        }
      }
    }

    if (_globalSingleton.translations == null) {
      String? translationsEncoded = _getStorage.read('translations');
      if (translationsEncoded == null || translationsEncoded == 'null') {
        await _refreshTranslations();
      } else {
        _globalSingleton.translations = json.decode(translationsEncoded);
      }
    }
  }

  Future<bool> _refreshTranslations() async {
    Map? newTranslations = await getTranslations(null, '/en');
    if (newTranslations.isNotEmpty) {
      _globalSingleton.translations = newTranslations;
      String translationsEncoded = json.encode(_globalSingleton.translations);
      _getStorage.write('translations', translationsEncoded);
      return true;
    }
    return false;
  }

  sendVerifyCode(context, data) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.sendResetCode}',
        data: data,
      );
      return checkResponse(response, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  resetPassword(context, data) async {
    try {
      Map response = await _networkDioHttp.postDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.resetPassword}',
        data: data,
      );
      if (response['error_description'] == null) {
        int statusCode = response['body']['statusCode'];
        if (statusCode == 200 || statusCode == 400) {
          return response['body'];
        } else {
          showErrorDialog(context);
          return response['body'];
        }
      } else {
        showErrorDialog(context);
        return response['body'];
      }
    } catch (e) {}
  }

  //account delete
  closeAccount(context) async {
    try {
      Map response = await _networkDioHttp.deleteDioHttpMethod(
        context: context,
        url: '${_apiEndpoints.apiEndPoint}${_apiEndpoints.closeAccount}',
      );
      return checkResponseWith500(response, context);
    } catch (e) {
      showErrorDialog('--------$e');
    }
  }

  void checkResponse(dynamic response, context) {
    if (response["error_description"] == null) {
      if (response['body']['statusCode'] == 200) {
        return response['body'];
      } else {
        showErrorDialog(response['body']['message']);
        return response['body'];
      }
    } else {
      if (context != null) showErrorDialog(response["error_description"]);
      return response['body'];
    }
  }

  LoginModel checkModelResponse(response, BuildContext? context) {
    if (response["error_description"] == null ||
        response["error_description"] == 'null') {
      LoginModel? loginModel;

      loginModel = LoginModel.fromJson(
        response['body'],
      );
      return loginModel;
    } else {
      print(response);
    }
    return LoginModel();
  }

  void checkResponseWith500(var response, BuildContext context) {
    if (response["error_description"] == null ||
        response["error_description"] == 'null') {
      int statusCode = response['body']['statusCode'];
      if (statusCode == 200) {
        return response['body'];
      } else if (statusCode == 500) {
        return response['body'];
      } else {
        showErrorDialog(response['message']);
      }
    } else {
      showErrorDialog(response["error_description"]);
    }
  }

  void showErrorDialog(String message) {
    ErrorDialog.showErrorDialog(message);
  }
}
