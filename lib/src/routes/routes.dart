import 'package:flutter/widgets.dart';

import '../../splash_screen.dart';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/': (BuildContext context) => IntroScreen(),
  // MainHomeScreen.routeName: (ctx) => MainHomeScreen(),
};
