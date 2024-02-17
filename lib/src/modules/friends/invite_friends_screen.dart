import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/modules/Questions/questions_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/dynamic_link_service.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:drive/src/widgets/listTile_effects.dart';
import 'package:drive/src/widgets/text_widgets/input_text_field_widget.dart';
import 'package:drive/src/widgets/user_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class InviteFriendsScreen extends StatefulWidget {
  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen>
    with WidgetsBindingObserver {
  ScrollController scrollController = ScrollController();
  UserContacts userContacts = locator<UserContacts>();
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  GetStorage getStorage = GetStorage();
  Timer? _timerLink;
  RxBool isLoading = false.obs;
  RxBool permission = false.obs;
  RxString searchData = ''.obs;
  RxList driveFriends = [].obs;
  RxList searchDriveFriends = [].obs;
  RxList allContacts = [].obs;
  RxList searchallContacts = [].obs;
  RxInt searchSkipCount = 0.obs;
  RxInt skipCount = 0.obs;
  RxInt totalContacts = 0.obs;
  RxString secretInviteCode = ''.obs;
  DynamicRepository _dynamicRepository = locator<DynamicRepository>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    scrollController = new ScrollController()..addListener(_scrollListener);
    debounce<String>(searchData, validations,
        time: const Duration(milliseconds: 500));
    getFriends('');
    getUserContacts(context);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(_scrollListener);
    WidgetsBinding.instance!.removeObserver(this);
    if (_timerLink != null) {
      _timerLink!.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = Timer(
        const Duration(milliseconds: 1000),
        () {},
      );
    }
  }

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (isLoading.value == false) {
        if (searchData.value != '') {
          searchSkipCount = searchSkipCount + 30;
          skipCount.value = 0;
          getContactsFormApi(
            isFromSearch: false,
            skip: searchSkipCount.value,
          );
        } else {
          skipCount = skipCount + 30;
          searchSkipCount.value = 0;
          getContactsFormApi(isFromSearch: false, skip: skipCount.value);
        }
      }
    }
  }

  void searchFunction(string) {
    searchData.value = string;
  }

  validations(String string) {
    skipCount.value = 0;
    searchSkipCount.value = 0;
    getFriends(searchData.value);
    getContactsFormApi(isFromSearch: true, skip: skipCount.value);
    searchDriveFriends.value = driveFriends
        .where((e) =>
            e['firstName'].toLowerCase().contains(
                  string.toLowerCase(),
                ) ||
            e['firstName'].toUpperCase().contains(
                  string.toUpperCase(),
                ))
        .toList();
    searchallContacts.value = allContacts.where(
      (u) {
        return u['displayName'] != null
            ? (u['displayName'].value.toLowerCase().contains(
                      string.toLowerCase(),
                    ) ||
                u['displayName'].value.toUpperCase().contains(
                      string.toUpperCase(),
                    ))
            : false;
      },
    ).toList();
  }

  getUserContacts(context) async {
    isLoading = true.obs;
    await userContacts.isContactsSave(context: context);
    permission.value = getStorage.read('saveContacts') ?? false;
    if (permission.value == true) {
      await getContactsFormApi(isFromSearch: false, skip: 0);
    }
    isLoading.value = false;
  }

  getContactsFormApi({bool? isFromSearch, int? skip}) async {
    Map getContactsData = {
      "skip": skip,
      "take": 30,
      "order": [],
      "filter": searchData.value == ''
          ? []
          : [
              {
                "field": "displayName",
                "value": searchData.value,
                "operator": 11
              }
            ],
      "group": []
    };
    dynamic response =
        await _networkRepository.getContacts(null, getContactsData);
    if (response != null &&
        (response['statusCode'] == 200 || response['statusCode'] == "200")) {
      if (isFromSearch == true) {
        allContacts.value = [];
        searchallContacts.value = [];
      }
      totalContacts.value = response['data']['rowCount'];
      for (int i = 0; i < response['data']['items'].length; i++) {
        allContacts.add({
          'identifier':
              response['data']['items'][i]['identifier'].toString().obs,
          'displayName':
              response['data']['items'][i]['displayName'].toString().obs,
          'isSentInvitation':
              (response['data']['items'][i]['isSentInvitation'] == true).obs,
          'uid': response['data']['items'][i]['uid'].toString().obs,
        }.obs);
        searchallContacts.add({
          'identifier':
              response['data']['items'][i]['identifier'].toString().obs,
          'displayName':
              response['data']['items'][i]['displayName'].toString().obs,
          'isSentInvitation':
              (response['data']['items'][i]['isSentInvitation'] == true).obs,
          'uid': response['data']['items'][i]['uid'].toString().obs,
        }.obs);
      }
    } else {
      ErrorDialog.showErrorDialog("${response['message']}");
    }
  }

  getFriends(data) async {
    Map frinedsData =
        await _networkRepository.getFriends(null, {'alias': data});
    if (frinedsData['statusCode'] == 200) {
      driveFriends.assignAll(frinedsData['data']);
      searchDriveFriends.assignAll(frinedsData['data']);
    }
  }

  Future<void> sendInvitation(context, index) async {
    Map response = await _networkRepository.sendInvitation(
        context, {"contactUid": searchallContacts[index]['uid'].toString()});
    if (response['statusCode'] == 200) {
      searchallContacts[index]['isSentInvitation'].value = true;
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  void qrCodeOnTap(context, uri) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.45,
          child: Column(
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 53,
                  padding: EdgeInsets.only(left: 28, right: 28),
                  margin: EdgeInsets.fromLTRB(0, 12, 0, 18),
                  decoration: BoxDecoration(
                      color: blackColor,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, bottom: 10.0),
                child: TextAndStyle(
                  title: "Scan QR code",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColor,
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: QrImage(
                  data: uri.toString(),
                  version: QrVersions.auto,
                  size: 230.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: appColor,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
          title: Obx(() => TextAndStyle(
                title: currentLanguage['stat_inviteFriend'],
                fontSize: 20,
                fontWeight: FontWeight.w700,
              )),
          actions: [
            if (GetStorage().read('uid') != null)
              FutureBuilder<Uri>(
                future: _dynamicRepository.createDynamicLink(
                  GetStorage().read('uid'),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Uri? uri = snapshot.data;
                    return Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              qrCodeOnTap(context, uri);
                            },
                            child: SvgPicture.asset(
                                'assets/icons/svg_icons/qr_code_scan.svg')),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          child: SvgPicture.asset(
                              'assets/icons/svg_icons/export.svg'),
                          onTap: () {
                            Share.share(uri.toString());
                          },
                        ),
                        SizedBox(
                          width: 22,
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
          child: Column(
            children: [
              SearchBar(
                controller: null,
                onChanged: (string) {
                  searchFunction(string);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Obx(
                        () => searchDriveFriends.length != 0
                            ? titleDecoration(
                                title: 'Drive Friends',
                                count: searchDriveFriends.length,
                              )
                            : SizedBox(),
                      ),
                      Obx(
                        () => ListView.builder(
                            itemCount: searchDriveFriends.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                                top: searchDriveFriends.length != 0
                                    ? 18.0
                                    : 0.0),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return driveFriendsListTile(index);
                            }),
                      ),
                      Obx(
                        () => titleDecoration(
                          title: currentLanguage['allContacts'],
                          count: totalContacts.value,
                        ),
                      ),
                      Obx(
                        () => isLoading.value == false &&
                                searchallContacts.isEmpty &&
                                isInternetOn.value
                            ? userContacts.noContactsOrPermission(
                                permission: permission.value,
                                enableOnTap: () async {
                                  bool getContacts =
                                      await userContacts.getContactList(
                                    context: context,
                                    isEnableClick: true,
                                  );
                                  if (getContacts == true) {
                                    await getContactsFormApi(
                                        isFromSearch: false, skip: 0);
                                  }
                                },
                              )
                            : ListView.builder(
                                itemCount:
                                    isLoading.value || !isInternetOn.value
                                        ? 5
                                        : searchallContacts.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.only(top: 18.0),
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  if (isLoading.value || !isInternetOn.value) {
                                    return ListTile(
                                      leading: CustomWidget.circular(
                                          height: 64, width: 64),
                                      title: Align(
                                        alignment: Alignment.centerLeft,
                                        child: CustomWidget.rectangular(
                                          height: 16,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                        ),
                                      ),
                                      subtitle:
                                          CustomWidget.rectangular(height: 14),
                                    );
                                  } else {
                                    return allContactsListTile(index);
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget titleDecoration({required String title, required int count}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Row(
        children: [
          TextAndStyle(
            title: title,
            fontSize: 16,
            color: blackColor,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            color: appColor.withOpacity(0.15),
            child: TextAndStyle(
              title: '$count',
              color: appColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget driveFriendsListTile(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        minLeadingWidth: 0.0,
        minVerticalPadding: 0.0,
        leading: CircleAvatar(
          maxRadius: 16.0,
          minRadius: 16.0,
          backgroundColor: appBackgroundColor,
          child: searchDriveFriends[index]['photoUrl'] != null
              ? CachedNetworkImage(
                  imageUrl: searchDriveFriends[index]['photoUrl'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    padding: EdgeInsets.all(20),
                    child: CupertinoActivityIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              : SvgPicture.asset('assets/icons/svg_icons/profile.svg'),
        ),
        contentPadding: EdgeInsets.zero,
        title: TextAndStyle(
          title: "${searchDriveFriends[index]['firstName']}",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: tabBarText,
        ),
      ),
    );
  }

  Widget allContactsListTile(index) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        minLeadingWidth: 0.0,
        minVerticalPadding: 0.0,
        leading: CircleAvatar(
          backgroundColor: appBackgroundColor,
          child: SvgPicture.asset('assets/icons/svg_icons/profile.svg'),
          maxRadius: 16.0,
          minRadius: 16.0,
        ),
        contentPadding: EdgeInsets.zero,
        title: Obx(
          () => TextAndStyle(
            title: searchallContacts[index]['displayName'].value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: tabBarText,
          ),
        ),
        trailing: Obx(
          () => GestureDetector(
            onTap: () {
              if (searchallContacts[index]['isSentInvitation'].value == false) {
                sendInvitation(context, index);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: searchallContacts[index]['isSentInvitation'].value
                    ? greyColor
                    : appColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: TextAndStyle(
                title: searchallContacts[index]['isSentInvitation'].value
                    ? 'Send'
                    : 'Invite',
                color: searchallContacts[index]['isSentInvitation'].value
                    ? whiteColor
                    : appColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
