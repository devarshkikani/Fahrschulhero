import 'package:drive/src/style/colors.dart';
import 'package:flutter/material.dart';

class CommonWidget extends StatelessWidget {
  Widget horizontalDivider() {
    return Divider(
      // height: 20,
      color: devidergrey,
    );
  }

  Widget customHorizontalDivider() {
    return Container(
      color: devidergrey,
      height: 1,
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
