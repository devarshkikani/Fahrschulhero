import 'dart:math';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/singleton/global_singleton.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

const kGoogleApiKey = "AIzaSyDZZeGlIGUIPs4o8ahJE_yq6pJv3GhbKQ8";

class SchoolListController extends GetxController {
  ScrollController scrollController = ScrollController();
  final GlobalSingleton _globalSingleton = locator<GlobalSingleton>();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  LatLng? searchLatLng;
  RxList schoolList = [].obs;
  RxList searchSchoolData = [].obs;
  RxInt skipCount = 0.obs;
  RxInt searchSkipCount = 0.obs;
  RxString searchData = 'Search'.obs;
  RxBool isLoading = true.obs;
  RxBool expandHeight = true.obs;

  @override
  void onInit() {
    scrollController = ScrollController()..addListener(_scrollListener);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (searchData.value == 'Search') {
        skipCount.value = skipCount.value + 10;
        await getSchool(isFromSearch: false, skip: skipCount.value);
      } else {
        searchSkipCount.value = searchSkipCount.value + 10;
        await getSchool(isFromSearch: false, skip: searchSkipCount.value);
      }
    }
  }

  Future<PermissionStatus> getPermission() async {
    final PermissionStatus permission = await Permission.location.status;
    if (permission == PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.location].request();
      return permissionStatus[Permission.location] ?? PermissionStatus.limited;
    } else {
      return permission;
    }
  }

  void getUserLocation() async {
    isLoading.value = true;
    final PermissionStatus permissionStatus = await getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Position currentPosition = await Geolocator.getCurrentPosition();
      _globalSingleton.latitude = currentPosition.latitude;
      _globalSingleton.longitude = currentPosition.longitude;
      // _globalSingleton.latitude = 50.1109;
      // _globalSingleton.longitude = 8.682;
      if (!isInternetOn.value) {
        showSnackBar(
          title: currentLanguage['noti_netErrorTitle'],
          message: currentLanguage['noti_netErrorSubtitle'],
          backgroundColor: appColor,
          colorText: whiteColor,
          margin: EdgeInsets.all(30),
        );
      } else {
        getSchool(
          skip: 0,
          isFromSearch: false,
        );
      }
    } else {
      isLoading.value = false;
    }
  }

  Future<void> getSchool({
    Map? data,
    bool? isFromSearch,
    int? skip,
  }) async {
    isLoading.value = true;
    Map schoolData = {
      "pagingData": {
        "skip": skip,
        "take": 10,
        "order": [],
        "filter": [],
        "group": []
      },
      "geographicArea": data ??
          {
            "radius": 50000,
            "latitude": _globalSingleton.latitude, //51.1657,
            "longitude": _globalSingleton.longitude, //10.4515
          }
    };
    Map response = await _networkRepository.getSchool(schoolData, null);
    if (response['statusCode'] == 200 || response['statusCode'] == '200') {
      if (isFromSearch == true) {
        schoolList.value = [];
        searchSchoolData.value = [];
        if (scrollController.positions.isNotEmpty) {
          scrollController.jumpTo(scrollController.position.minScrollExtent);
        }
      }
      schoolList.addAll(response['data']['items']);
      searchSchoolData.addAll(response['data']['items']);
      isLoading.value = false;
    } else {
      ErrorDialog.showErrorDialog(
        response['message'] ?? 'Something went wrong',
      );
    }
  }

  String distanceOfSchool(double latitude, double longitude, String address) {
    if (_globalSingleton.latitude != null &&
        _globalSingleton.longitude != null) {
      double distanceInKM = calculateDistance(latitude, longitude,
          _globalSingleton.latitude, _globalSingleton.longitude);
      String distance = distanceInKM.toStringAsFixed(1);
      return distance;
    } else {
      return address;
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> handleSearchButton(context) async {
    Mode _mode = Mode.overlay;
    expandHeight.value = false;
    try {
      Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: _mode,
          language: "en",
          types: [],
          components: [],
          strictbounds: false);
      displayPrediction(p);
    } catch (e) {
      expandHeight.value = true;
      print(e);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
    Get.snackbar("Error", response.errorMessage.toString());
  }

  Future<Null> displayPrediction(Prediction? p) async {
    if (p != null) {
      searchData.value = p.description.toString();
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse details =
          await _places.getDetailsByPlaceId(p.placeId ?? '000');
      searchLatLng = LatLng(details.result.geometry!.location.lat,
          details.result.geometry!.location.lng);
      Map data = {
        "radius": 50000,
        "latitude": searchLatLng!.latitude,
        "longitude": searchLatLng!.longitude,
      };
      searchSkipCount.value = 0;
      getSchool(
        data: data,
        isFromSearch: true,
        skip: searchSkipCount.value,
      );
    } else {
      searchData.value = 'Search';
      getSchool(
        isFromSearch: true,
        skip: 0,
      );
    }
    Future.delayed(const Duration(seconds: 1), () {
      expandHeight.value = true;
    });
  }
}
