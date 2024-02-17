import 'dart:io';

import 'package:flutter/material.dart';

class CommonMethod extends StatefulWidget {
  int getPlatform() => Platform.isIOS
      ? 1
      : Platform.isAndroid
          ? 2
          : 0;

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}
