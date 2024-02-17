import 'package:cached_network_image/cached_network_image.dart';
import 'package:drive/src/binding/school_detail_binding.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/school_list_controller.dart';
import 'package:drive/src/modules/school_list/school_detail/school_detail_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/app_constants.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/widgets/listTile_effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class SchoolListScreen extends GetView<SchoolListController> {
  final ApiEndpoints _appConstants = locator<ApiEndpoints>();

  @override
  Widget build(BuildContext context) {
    controller.getUserLocation();
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: appColor,
          elevation: 0.0,
          title: TextAndStyle(
            title: 'Driving School List',
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                controller.handleSearchButton(context);
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(25, 12, 25, 12),
                padding: EdgeInsets.all(12),
                height: 45,
                decoration: BoxDecoration(
                    color: whiteColor,
                    border: Border.all(color: greyColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: textGreyColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Obx(
                      () => TextAndStyle(
                        title: controller.searchData.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              return controller.searchSchoolData.length != 0
                  ? Expanded(
                      child: SingleChildScrollView(
                        controller: controller.scrollController,
                        child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 0),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: controller.searchSchoolData.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              return listItem(
                                  controller.searchSchoolData[index], index);
                            }),
                      ),
                    )
                  : Container(
                      height: controller.expandHeight.value
                          ? Get.height / 1.6
                          : 0.0,
                      alignment: controller.isLoading.value
                          ? Alignment.topCenter
                          : Alignment.center,
                      child: controller.isLoading.value
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: 6,
                              itemBuilder: (BuildContext context, int index) =>
                                  buildMovieShimmer(context),
                            )
                          : TextAndStyle(
                              title: currentLanguage['school_noSchoolFound'],
                            ),
                    );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildMovieShimmer(context) {
    return ListTile(
      leading: CustomWidget.circular(
        height: 64,
        width: 64,
        baseColor: grey300,
        highlightColor: grey300.withOpacity(0.10),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: CustomWidget.rectangular(
          height: 16,
          width: MediaQuery.of(context).size.width * 0.3,
          baseColor: grey300,
          highlightColor: grey300.withOpacity(0.10),
        ),
      ),
      subtitle: CustomWidget.rectangular(
        height: 14,
        baseColor: grey300,
        highlightColor: grey300.withOpacity(0.10),
      ),
    );
  }

  Widget listItem(Map item, int index) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            schoolData.value = item;
            Get.to(
                () => SchoolDetailScreen(
                    // schoolData: item,
                    ),
                binding: SchoolDetailBindings());
          },
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primaryWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl:
                        "${_appConstants.imageEndPoint}/Schools/${item['id']}.png",
                    height: 63,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      padding: EdgeInsets.all(20),
                      child: CupertinoActivityIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 63,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextAndStyle(
                          title: item['name'],
                          textOverflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          maxLine: 1,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: textGrey,
                              size: 12,
                            ),
                            TextAndStyle(
                              title: controller.distanceOfSchool(
                                      item['latitude'],
                                      item['longitude'],
                                      item['streetNumber'] +
                                          item['streetName']) +
                                  ' km away',
                              color: textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                        TextAndStyle(
                          title: "Class  " + item['classes'],
                          color: textGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if ((index + 1) == controller.searchSchoolData.length)
          Container(
            height: 70,
            child: controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink(),
          ),
      ],
    );
  }
}
