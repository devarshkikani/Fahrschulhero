import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/school_detail_controller.dart';
import 'package:drive/src/controller/school_list_controller.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
RxMap schoolData = {}.obs;

// ignore: must_be_immutable
class SchoolDetailScreen extends GetView<SchoolDetailController> {
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();

  List<Map<String, String>> openingHours = [
    {
      "day": "MONDAY",
      "start": schoolData['mondayStart'].toString(),
      "end": schoolData['mondayEnd'].toString()
    },
    {
      "day": "TUESDAY",
      "start": schoolData['tuesdayStart'].toString(),
      "end": schoolData['tuesdayEnd'].toString(),
    },
    {
      "day": "WEDNESDAY",
      "start": schoolData['wednesdayStart'].toString(),
      "end": schoolData['wednesdayEnd'].toString()
    },
    {
      "day": "THURSDAY",
      "start": schoolData['thursdayStart'].toString(),
      "end": schoolData['thursdayEnd'].toString()
    },
    {
      "day": "FRIDAY",
      "start": schoolData['fridayStart'].toString(),
      "end": schoolData['fridayEnd'].toString()
    },
    {
      "day": "SATURDAY",
      "start": schoolData['saturdayStart'].toString(),
      "end": schoolData['saturdayEnd'].toString()
    },
    {
      "day": "SUNDAY",
      "start": schoolData['sundayStart'].toString(),
      "end": schoolData['sundayEnd'].toString()
    },
  ];

  @override
  Widget build(BuildContext context) {
    controller.panelHeightOpen = MediaQuery.of(context).size.height;

    return Scaffold(
      key: controller.scaffoldkey,
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: controller.panelController,
            padding: EdgeInsets.all(10),
            color: appBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            maxHeight: controller.panelHeightOpen ?? 0.0,
            minHeight: controller.panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: 0.55,
            snapPoint: 0.50,
            defaultPanelState: PanelState.OPEN,
            isDraggable: true,
            backdropTapClosesPanel: true,
            panelSnapping: true,
            body: panelBody(), //controller.panelController.isPanelOpen
            panel: bottomSheetWidget(),
            onPanelSlide: (double position) {
              if (position.toInt() == 1) {
                controller.showPadding.value = true;
              } else {
                controller.showPadding.value = false;
              }
            },
            onPanelClosed: () {},
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                constraints: BoxConstraints(),
                icon: Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget panelBody() {
    controller.createMarker({
      "clubId": schoolData['name'],
      "latitude": schoolData['latitude'],
      "longitude": schoolData['longitude'],
    }, 10.0);
    return Stack(
      children: [
        Obx(
          () => GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.initialcameraposition,
              zoom: 10.5,
            ),
            polylines: Set<Polyline>.of(controller.polylines.values),
            mapType: MapType.normal,
            compassEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onTap: (argument) => controller.onMapTap(),
            markers: controller.markers,
            onMapCreated: controller.onMapCreated,
          ),
        ),
      ],
    );
  }

  Widget bottomSheetWidget() {
    return Container(
      color: appBackgroundColor,
      padding: EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Obx(
              () => SizedBox(
                height: controller.showPadding.value ? 50.0 : 0.0,
              ),
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl:
                        "${_appConstants.imageEndPoint}/Schools/${schoolData['id']}.png",
                    height: 51,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      padding: EdgeInsets.all(20),
                      child: CupertinoActivityIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextAndStyle(
                      title: 'Driving School Mueller',
                      fontWeight: FontWeight.w500,
                      color: tabBarText,
                      fontSize: 16,
                    ),
                    RatingBar.builder(
                      initialRating: 4,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.zero,
                      itemSize: 20,
                      unratedColor: bordergrey,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 17,
            ),
            listTile(
              title:
                  schoolData['streetNumber'] + ", " + schoolData['streetName'],
              subTitle: Get.find<SchoolListController>().distanceOfSchool(
                      schoolData['latitude'],
                      schoolData['longitude'],
                      schoolData['streetNumber'] + schoolData['streetName']) +
                  ' km away',
              icon: "assets/icons/svg_icons/location.svg",
            ),
            listTile(
              title: schoolData['phoneNumber'],
              icon: "assets/icons/svg_icons/call.svg",
              trailing: currentLanguage['school_call'],
            ),
            listTile(
                title: schoolData['email'],
                icon: "assets/icons/svg_icons/mail.svg",
                trailing: currentLanguage['school_sendEmail']),
            SizedBox(
              height: 10,
            ),
            detailsDecoration(
              title: currentLanguage['school_language'],
              trailing: schoolData['languages'],
            ),
            detailsDecoration(
              title: currentLanguage['school_classes'],
              trailing: schoolData['classes'],
            ),
            detailsDecoration(
              title: currentLanguage['school_openingHours'],
              trailing: "",
              subTitle: ListView.builder(
                itemCount: openingHours.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 18, bottom: 15),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  DateTime? startDate, endDate;
                  if (openingHours[index]["start"] != 'null' &&
                      openingHours[index]["end"] != 'null') {
                    startDate = DateFormat('hh:mm')
                        .parse(openingHours[index]["start"].toString());
                    endDate = DateFormat('hh:mm')
                        .parse(openingHours[index]["end"].toString());
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        TextAndStyle(
                          title: openingHours[index]["day"],
                          color: textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                        Spacer(),
                        TextAndStyle(
                          title: startDate == null && endDate == null
                              ? currentLanguage['school_closed']
                              : DateFormat('hh:mm')
                                      .format(startDate!)
                                      .toString() +
                                  ' - ' +
                                  DateFormat('hh:mm')
                                      .format(endDate!)
                                      .toString(),
                          color: startDate == null && endDate == null
                              ? redColor
                              : textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listTile(
      {required String title,
      String? subTitle,
      required String icon,
      String? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 6),
      child: Row(
        children: [
          SvgPicture.asset(icon),
          SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextAndStyle(
                title: title,
                color: textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              if (subTitle != null)
                TextAndStyle(
                  title: subTitle,
                  color: textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
          Spacer(),
          if (trailing != null)
            GestureDetector(
              onTap: () {
                if (icon == 'Call') {
                  launch('tel: $title');
                } else {
                  launch('mailto:$title');
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(12, 5, 12, 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: appColor.withOpacity(0.15),
                ),
                child: TextAndStyle(
                  title: trailing,
                  color: appColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget detailsDecoration(
      {required String title, required String trailing, Widget? subTitle}) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
      padding: EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: whiteColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              TextAndStyle(
                title: title,
                color: blackColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              Spacer(),
              TextAndStyle(
                title: trailing,
                color: textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          if (subTitle != null) subTitle,
        ],
      ),
    );
  }
}
