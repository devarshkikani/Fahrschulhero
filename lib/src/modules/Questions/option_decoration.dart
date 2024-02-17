import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

RxMap select = {}.obs;
RxMap<String, dynamic> seletedMap = <String, dynamic>{}.obs;
RxBool nextQuestion = false.obs;

// ignore: must_be_immutable
class OptionDecoration extends GetView {
  final int index;
  final String optionIndex;
  final bool? overview;
  final bool? isFromExam;
  final Map<RxString, RxString> option;
  final String? givenAnswer;
  OptionDecoration({
    required this.index,
    required this.option,
    required this.optionIndex,
    this.overview,
    this.isFromExam,
    this.givenAnswer,
  });
  RxBool selected = false.obs;
  @override
  Widget build(BuildContext context) {
    if (isFromExam == true && seletedMap.isNotEmpty) {
      selected.value = seletedMap.values.toList()[index] == "1" ? true : false;
    }
    if (overview == true) {
      if (givenAnswer == null || givenAnswer!.isEmpty) {
        selected.value = false;
      } else {
        selected.value =
            givenAnswer!.split('').toList()[index] == '1' ? true : false;
      }
      print(option);
    }
    return GestureDetector(
      onTap: () {
        if (overview != true) {
          if (nextQuestion.value == false) {
            selected.value = !selected.value;
            if (selected.value) {
              seletedMap['$optionIndex'] = '1';
              select.addAll({optionIndex.toString(): '1'});
            } else {
              seletedMap['$optionIndex'] = '0';
              select.remove(optionIndex.toString());
            }
          }
        }
      },
      child: Obx(
        () => Container(
          constraints: new BoxConstraints(
            minHeight: 53.0,
          ),
          padding: EdgeInsets.only(
            left: 12,
          ),
          margin: EdgeInsets.fromLTRB(18, 0, 18, 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: overview == true ? Colors.transparent : primaryWhite,
            border: Border.all(
              color: selected.value
                  ? isFromExam == true
                      ? greenColor
                      : appColor
                  : overview == true
                      ? whiteColor
                      : bordergrey,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 24,
                width: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: overview == true ? Colors.transparent : whiteColor,
                  border: Border.all(
                      color: overview == true ? whiteColor : greyColor),
                ),
                child: givenAnswer == '000' && overview == true
                    ? (option.values.toList()[0].toString() == '1')
                        ? SvgPicture.asset('assets/icons/svg_icons/right.svg')
                        : null
                    : nextQuestion.value || overview == true
                        ? selected.value ==
                                (option.values.toList()[0].toString() == '1'
                                    ? true
                                    : false)
                            ? SvgPicture.asset(
                                'assets/icons/svg_icons/right.svg')
                            : SvgPicture.asset(
                                'assets/icons/svg_icons/wrong.svg')
                        : selected.value
                            ? SvgPicture.asset(
                                'assets/icons/svg_icons/right.svg',
                                color: appColor,
                              )
                            : SizedBox(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: TextAndStyle(
                    // title: option.keys.toString(),
                    title: option.keys.toList()[0].toString(),
                    fontFamily: "Rubik",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: optionText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
