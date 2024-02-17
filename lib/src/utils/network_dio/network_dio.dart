import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:drive/src/binding/authentication_binding.dart';
import 'package:drive/src/controller/question_screen_controller.dart';
import 'package:drive/src/database/database_helper.dart';
import 'package:drive/src/models/login_model.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/modules/login/signin_screen.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/internet_error.dart';
import 'package:drive/src/utils/process_indicator.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:synchronized/synchronized.dart' as Synchronized;
import '../locator.dart';

class NetworkDioHttp {
  Dio? _dio;
  String? endPointUrl;
  DioCacheManager? _dioCacheManager;
  Options _cacheOptions =
      buildCacheOptions(Duration(seconds: 1), forceRefresh: true);
  Circle processIndicator = Circle();
  GetStorage _getStorage = GetStorage();
  final InternetError internetError = locator<InternetError>();
  final ApiEndpoints _apiEndpoints = locator<ApiEndpoints>();
  DatabaseHelper databaseHelper = DatabaseHelper();
  final Synchronized.Lock _refreshTokenLock = new Synchronized.Lock();
  RxBool isAPICalling = false.obs;

  Future<Map<String, String>> _getHeaders() async {
    final String? token = _getStorage.read('token');
    print('~~~~~~~~~~~~~~~~~~~~ SET HEADER : $token ~~~~~~~~~~~~~~~~~~~');
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } else {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  setDynamicHeader({required String endPoint}) async {
    endPointUrl = endPoint;
    BaseOptions options =
        BaseOptions(receiveTimeout: 50000, connectTimeout: 50000);
    _dioCacheManager = DioCacheManager(CacheConfig());
    final token = await _getHeaders();
    options.headers.addAll(token);
    _dio = Dio(options);
    _dio!.interceptors.add(_dioCacheManager!.interceptor);
    if (Platform.isIOS) {
      networkListner();
    }
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult event) async {
      networkListner();
    });
  }

  Future<void> networkListner() async {
    if (await check()) {
      print('+++++++ Internet available +++++++');
      if (!isAPICalling.value) {
        isInternetOn.value = true;
        await pendingAnsweredQuestionsAPI();
        await pendingIsFavoriteAPI();
      } else {
        print('+++++ API Calling +++++');
      }
    } else {
      print('+++++++ Are you Offline +++++++');
      isInternetOn.value = false;
    }
  }

  pendingAnsweredQuestionsAPI() async {
    if (_getStorage.read('pendingAnsweredQuestions') != null) {
      final pendingData =
          _getStorage.read('pendingAnsweredQuestions') as List<dynamic>;
      if (pendingData.isNotEmpty) {
        isAPICalling.value = true;
        final response =
            await NetworkRepository().answerMultiple(null, pendingData);
        if (response != null && response['statusCode'] == 200) {
          _getStorage.remove(('pendingAnsweredQuestions'));
          offlineAnswered.value = [];
          isAPICalling.value = false;
        } else {
          Future.delayed(Duration(seconds: 30), () {
            pendingAnsweredQuestionsAPI();
          });
        }
      }
    }
  }

  pendingIsFavoriteAPI() async {
    if (_getStorage.read('pendingIsFavorite') != null) {
      final pendingFavoriteData =
          _getStorage.read('pendingIsFavorite') as List<dynamic>;
      if (pendingFavoriteData.isNotEmpty) {
        Map? response;
        for (int i = 0; i < pendingFavoriteData.length; i++) {
          response = await NetworkRepository()
              .setFavorite(null, pendingFavoriteData[i]);
        }
        if (response != null && response['statusCode'] == 200) {
          offlineIsFavorite.value = [];
          _getStorage.remove(('pendingIsFavorite'));
        } else {
          Future.delayed(Duration(seconds: 30), () {
            pendingIsFavoriteAPI();
          });
        }
      }
    }
  }

  //Get Method
  Future<Map<String, dynamic>> getDioHttpMethod(
      {BuildContext? context, required String url}) async {
    var internet = await check();
    if (internet) {
      if (context != null) processIndicator.show(context);
      try {
        print('+++url: $url');
        Response response = await _dio!.get("$url", options: _cacheOptions);
        print('+++response: $response');
        var responseBody;
        if (response.statusCode == 200) {
          try {
            responseBody = json.decode(response.data);
          } catch (e) {
            responseBody = response.data;
          }
          Map<String, dynamic> data = {
            'body': responseBody,
            'headers': response.headers,
            'error_description': null,
          };
          if (context != null) processIndicator.hide(context);
          return data;
        } else {
          if (context != null) processIndicator.hide(context);
          return {
            'body': null,
            'headers': null,
            'error_description': "Something Went Wrong",
          };
        }
      } catch (e) {
        print('~~~~~$e');
        if (context != null) processIndicator.hide(context);
        return await handleErrorRefreshToken(e, context, url, null, 'get');
      }
    } else {
      Map<String, dynamic> responseData = {
        'body': null,
        'headers': null,
        'error_description': "Internet Error",
      };
      if (context != null) internetError.addOverlayEntry(context);
      return responseData;
    }
  }

  //Put Method
  Future<Map<String, dynamic>> putDioHttpMethod(
      {BuildContext? context, required String url, required data}) async {
    var internet = await check();
    if (internet) {
      if (context != null) processIndicator.show(context);
      try {
        print('+++URL: $url');
        Response response = await _dio!.put(
          "$url",
          data: data,
          options: _cacheOptions,
        );
        print('+++response: $response');
        var responseBody;

        if (response.statusCode == 200) {
          if (context != null) processIndicator.hide(context);
          try {
            responseBody = json.decode(json.encode(response.data));
          } catch (e) {
            responseBody = response.data;
          }

          return {
            'body': responseBody,
            'headers': response.headers,
            'error_description': null,
          };
        } else {
          if (context != null) processIndicator.hide(context);
          return {
            'body': null,
            'headers': null,
            'error_description': "Something Went Wrong",
          };
        }
      } catch (e) {
        print('+++~~~~~$e');
        if (context != null) processIndicator.hide(context);
        return await handleErrorRefreshToken(e, context, url, data, 'put');
      }
    } else {
      Map<String, dynamic> responseData = {
        'body': null,
        'headers': null,
        'error_description': "Internet Error",
      };
      if (context != null) internetError.addOverlayEntry(context);
      return responseData;
    }
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  //Post Method
  dynamic postDioHttpMethod(
      {BuildContext? context, required String url, required data}) async {
    var internet = await check();
    if (internet) {
      if (context != null) processIndicator.show(context);
      try {
        print("+++URL :" + "$url");
        print('+++Data: ' + '$data');
        Response response = await _dio!.post(
          "$url",
          data: data,
          options: _cacheOptions,
        );
        print('+++Response: ' + '$response');
        var responseBody;
        if (context != null) processIndicator.hide(context);

        if (response.statusCode == 200) {
          try {
            responseBody = json.decode(json.encode(response.data));
          } catch (e) {
            responseBody = response.data;
          }
          return {
            'body': responseBody,
            'headers': response.headers,
            'error_description': null,
          };
        } else {
          return {
            'body': response.data,
            'headers': null,
            'error_description': response.data['Message'],
          };
        }
      } catch (e) {
        print('+++~~~~~$e');
        if (context != null) processIndicator.hide(context);
        return await handleErrorRefreshToken(e, context, url, data, 'post');
      }
    } else {
      Map<String, dynamic> responseData = {
        'body': null,
        'headers': null,
        'error_description': "Internet Error",
      };
      if (context != null) internetError.addOverlayEntry(context);
      return responseData;
    }
  }

  Future<Map<String, dynamic>> handleErrorRefreshToken(dynamic error,
      BuildContext? context, String url, data, String type) async {
    Map<String, dynamic> responseData = {};
    DioError dioError = error as DioError;

    // Unauthorized
    if (dioError.response?.statusCode == 401) {
      int statusCode = await _refreshTokenLock.synchronized(() async {
        return await refreshToken(context);
      });

      if (statusCode == 409 || statusCode == 123) {
        responseData = {
          'body': null,
          'headers': null,
          'error_description': 'We didn' 't manage to refresh your auth token',
        };
      } else {
        return await reExecuteRequest(type, context, url, data);
      }
    } else {
      responseData = {
        'body': null,
        'headers': null,
        'error_description': await _handleError(error, context),
      };
    }
    return responseData;
  }

  Future<dynamic> reExecuteRequest(
      String type, BuildContext? context, String url, data) async {
    dynamic response = await (type == "post"
        ? postDioHttpMethod(context: context, url: url, data: data)
        : type == "get"
            ? getDioHttpMethod(context: context, url: url)
            : type == "put"
                ? putDioHttpMethod(context: context, url: url, data: data)
                : type == "delete"
                    ? deleteDioHttpMethod(
                        context: context, url: url, data: data)
                    : throw ('Not implemented handler for the type = $type'));

    return response;
  }

  refreshToken(BuildContext? context) async {
    final NetworkRepository _networkRepository = locator<NetworkRepository>();
    String? token = _getStorage.read('token');
    String? refreshToken = _getStorage.read('refreshToken');

    if (token == null || refreshToken == null) {
      return 123;
    }

    Map tokenData = {
      "token": token.toString(),
      "refreshToken": refreshToken.toString()
    };

    LoginModel? response = await _networkRepository.getRefreshToken(tokenData);

    if (response != null) {
      if (response.statusCode == 200) {
        await _getStorage.write('token', response.data!.token.toString());
        await _getStorage.write(
            'refreshToken', response.data!.refreshToken.toString());
        await setDynamicHeader(endPoint: _apiEndpoints.apiEndPoint);
      } else if (response.statusCode == 409) {
        _getStorage.erase();
        await databaseHelper.deleteTable();
        final response = await _networkRepository.getConfigurations(null);
        if (response != null && response['statusCode'] == 200) {
          _getStorage.write(
              'questionVersion', response['data']['questionVersion']);
          _getStorage.write(
              'translationVersion', response['data']['translationVersion']);
          _getStorage.write('adBannerTimeoutSeconds',
              response['data']['adBannerTimeoutSeconds']);
        }
        Future.delayed(const Duration(seconds: 3), () {
          Get.offAll(
            () => SigninScreen(),
            binding: AuthenticationBinding(),
          );
        });
      }
      return response.statusCode;
    } else {
      return 500;
    }
  }

  //Delete Method
  Future<Map<String, dynamic>> deleteDioHttpMethod(
      {BuildContext? context, required String url, data}) async {
    var internet = await check();
    if (internet) {
      if (context != null) processIndicator.show(context);
      try {
        Response response = await _dio!.delete(
          "$url",
          data: data,
          options: _cacheOptions,
        );
        var responseBody;

        if (response.statusCode == 200) {
          if (context != null) processIndicator.hide(context);
          try {
            responseBody = json.decode(json.encode(response.data));
          } catch (e) {
            responseBody = response.data;
          }
          return {
            'body': responseBody,
            'headers': response.headers,
            'error_description': null,
          };
        } else {
          if (context != null) processIndicator.hide(context);
          return {
            'body': null,
            'headers': null,
            'error_description': "Something Went Wrong",
          };
        }
      } catch (e) {
        return await handleErrorRefreshToken(e, context, url, null, 'delete');
      }
    } else {
      Map<String, dynamic> responseData = {
        'body': null,
        'headers': null,
        'error_description': "Internet Error",
      };
      internetError.addOverlayEntry(context);
      return responseData;
    }
  }

  //Multiple Concurrent
  Future<Map<String, dynamic>> multipleConcurrentDioHttpMethod(
      {BuildContext? context,
      required String getUrl,
      required String postUrl,
      required Map<String, dynamic> postData}) async {
    try {
      if (context != null) processIndicator.show(context);
      List<Response> response = await Future.wait([
        _dio!.post("$endPointUrl/$postUrl",
            data: postData, options: _cacheOptions),
        _dio!.get("$endPointUrl/$getUrl", options: _cacheOptions)
      ]);
      if (response[0].statusCode == 200 || response[0].statusCode == 200) {
        if (response[0].statusCode == 200 && response[1].statusCode != 200) {
          if (context != null) processIndicator.hide(context);
          return {
            'getBody': null,
            'postBody': json.decode(response[0].data),
            'headers': response[0].headers,
            'error_description': null,
          };
        } else if (response[1].statusCode == 200 &&
            response[0].statusCode != 200) {
          if (context != null) processIndicator.hide(context);
          return {
            'getBody': null,
            'postBody': json.decode(response[0].data),
            'headers': response[0].headers,
            'error_description': null,
          };
        } else {
          if (context != null) processIndicator.hide(context);
          return {
            'postBody': json.decode(response[0].data),
            'getBody': json.decode(response[0].data),
            'headers': response[0].headers,
            'error_description': null,
          };
        }
      } else {
        if (context != null) processIndicator.hide(context);
        return {
          'postBody': null,
          'getBody': null,
          'headers': null,
          'error_description': "Something Went Wrong",
        };
      }
    } catch (e) {
      Map<String, dynamic> responseData = {
        'postBody': null,
        'getBody': null,
        'headers': null,
        'error_description': await _handleError(e, context),
      };
      if (context != null) processIndicator.hide(context);
      return responseData;
    }
  }

  //Sending FormData
  Future<Map<String, dynamic>> sendingFormDataDioHttpMethod(
      {BuildContext? context,
      required String url,
      required Map<String, dynamic> data}) async {
    var internet = await check();
    if (internet) {
      try {
        if (context != null) processIndicator.show(context);
        FormData formData = FormData.fromMap(data);
        Response response = await _dio!
            .post("$endPointUrl$url", data: formData, options: _cacheOptions);
        if (response.statusCode == 200) {
          if (context != null) processIndicator.hide(context);
          return {
            'body': json.decode(response.data),
            'headers': response.headers,
            'error_description': null,
          };
        } else {
          if (context != null) processIndicator.hide(context);
          return {
            'body': null,
            'headers': null,
            'error_description': "Something Went Wrong",
          };
        }
      } catch (e) {
        Map<String, dynamic> responseData = {
          'body': null,
          'headers': null,
          'error_description': await _handleError(e, context),
        };
        if (context != null) processIndicator.hide(context);
        return responseData;
      }
    } else {
      Map<String, dynamic> responseData = {
        'body': null,
        'headers': null,
        'error_description': "Internet Error",
      };
      internetError.addOverlayEntry(context);
      return responseData;
    }
  }

  //Handle Error
  Future<String> _handleError(error, context) async {
    String errorDescription = "";
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (error is DioError) {
          // ignore: unnecessary_cast
          DioError dioError = error as DioError;
          switch (dioError.type) {
            case DioErrorType.connectTimeout:
              break;
            case DioErrorType.sendTimeout:
              break;
            case DioErrorType.receiveTimeout:
              errorDescription =
                  "Receive timeout in connection with API server";
              break;
            case DioErrorType.response:
              errorDescription =
                  "Received invalid status code: ${dioError.response!.statusCode}";
              break;
            case DioErrorType.cancel:
              errorDescription = "Request to API server was cancelled";
              break;
            case DioErrorType.other:
              errorDescription =
                  "Connection to API server failed due to internet connection";
              break;
          }
        } else {
          errorDescription = "Unexpected error occured";
        }
      }
    } on SocketException catch (_) {
      errorDescription = "Please check your internet connection";
    }

    if (errorDescription.contains("401")) {
      final NetworkRepository _networkRepository = locator<NetworkRepository>();
      String? token = _getStorage.read('token');
      String? refreshToken = _getStorage.read('refreshToken');
      final classId = _getStorage.read('classId');
      final language = _getStorage.read('language');
      final isSubscribe = _getStorage.read('isSubscribe');
      final subscriptionDate = _getStorage.read('subscriptionDate');
      final translation = _getStorage.read('translation');
      final translationVersion = _getStorage.read('translationVersion');
      final questionVersion = _getStorage.read('questionVersion');
      Map tokenData = {
        "token": token.toString(),
        "refreshToken": refreshToken.toString()
      };
      LoginModel? response =
          await _networkRepository.getRefreshToken(tokenData);

      if (response != null && response.statusCode == 200) {
        _getStorage.erase();
        _getStorage.write('token', response.data!.token.toString());
        _getStorage.write(
            'refreshToken', response.data!.refreshToken.toString());
        _getStorage.write('userName', response.data!.user!.username.toString());
        _getStorage.write(
            'phoneNumber', response.data!.user!.phoneNumber.toString());
        _getStorage.write('userId', response.data!.user!.id.toString());
        _getStorage.write('uid', response.data!.user!.uid.toString());
        _getStorage.write('email', response.data!.user!.email.toString());
        _getStorage.write(
            'firstName', response.data!.user!.firstName.toString());
        _getStorage.write('photoUrl', response.data!.user!.photoUrl.toString());
        _getStorage.write('classId', classId);
        _getStorage.write('language', language);
        _getStorage.write('isSubscribe', isSubscribe);
        _getStorage.write('subscriptionDate', subscriptionDate);
        _getStorage.write('translation', translation);
        _getStorage.write('translationVersion', translationVersion);
        _getStorage.write('questionVersion', questionVersion);
        _getStorage.write('isLoggedIn', true);
        await setDynamicHeader(endPoint: _apiEndpoints.apiEndPoint);
      } else {
        await _getStorage.erase();
        await databaseHelper.deleteTable();
        _getStorage.write('translationVersion', translationVersion);
        _getStorage.write('questionVersion', questionVersion);
        Get.offAll(
          () => SigninScreen(),
          binding: AuthenticationBinding(),
        );
      }
    }

    return errorDescription;
  }
}
