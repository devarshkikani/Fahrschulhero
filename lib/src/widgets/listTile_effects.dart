import 'package:drive/src/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final Color? baseColor;
  final Color? highlightColor;

  const CustomWidget.rectangular(
      {this.width = double.infinity,
      required this.height,
      this.baseColor,
      this.highlightColor})
      : this.shapeBorder = const RoundedRectangleBorder();

  const CustomWidget.circular(
      {this.width = double.infinity,
      required this.height,
      this.baseColor,
      this.highlightColor,
      this.shapeBorder = const CircleBorder()});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: baseColor ?? lightBlue,
        highlightColor: highlightColor ?? highlightblue,
        period: Duration(seconds: 2),
        child: Container(
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: highlightblue,
            shape: shapeBorder,
          ),
        ),
      );
}
