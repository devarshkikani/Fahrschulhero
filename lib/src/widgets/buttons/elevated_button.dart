import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SecondaryButton extends StatelessWidget {
  String? title;
  VoidCallback onPressed;
  Color? color;
  SecondaryButton({
    Key? key,
    this.title,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 17, horizontal: 5),
        decoration: BoxDecoration(
          color: appColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextAndStyle(
              title: title,
              letterSpacing: 0.2,
              color: whiteColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
