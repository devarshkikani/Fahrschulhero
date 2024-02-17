import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OutlineButtonWidget extends StatelessWidget {
  String? title;
  VoidCallback onPressed;
  VoidCallback? onLongPress;
  double? height;
  double? radius;
  double? fontSize;
  Color? color;
  Color? textColor;
  Color? borderColor;
  ButtonTextTheme? textTheme;

  OutlineButtonWidget({
    Key? key,
    this.title,
    required this.onPressed,
    this.height,
    this.color,
    this.fontSize,
    this.radius,
    this.textColor,
    this.borderColor,
    this.onLongPress,
    this.textTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 17, horizontal: 5),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appColor,
          ),
        ),
        child: Center(
          child: TextAndStyle(
            title: title,
            letterSpacing: 0.2,
            color: appColor,
            fontSize: 15,
            maxLine: 3,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
