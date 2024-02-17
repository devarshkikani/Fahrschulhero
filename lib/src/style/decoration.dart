import 'package:drive/src/style/colors.dart';
import 'package:flutter/cupertino.dart';

TextStyle whiteBoldText =
    TextStyle(color: primaryWhite, fontSize: 16, fontWeight: FontWeight.w700);

class TextAndStyle extends StatelessWidget {
  final String? title;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int? maxLine;
  final TextDecoration? textDecoration;
  TextAndStyle({
    Key? key,
    this.title,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.letterSpacing,
    this.fontFamily,
    this.textAlign,
    this.maxLine,
    this.textOverflow,
    this.textDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toString(),
      textAlign: textAlign,
      overflow: textOverflow,
      maxLines: maxLine,
      style: TextStyle(
        fontSize: fontSize ?? 16.0,
        color: color,
        fontWeight: fontWeight ?? FontWeight.w400,
        letterSpacing: letterSpacing ?? 0.0,
        decoration: textDecoration,
        fontFamily: fontFamily ?? 'CeraPro',
      ),
    );
  }
}
