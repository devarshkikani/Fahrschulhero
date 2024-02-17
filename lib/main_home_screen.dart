import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/controller/main_home_controller.dart';
import 'package:drive/src/modules/home/home_screen.dart';
import 'package:drive/src/modules/settings/settings_screen.dart';
import 'package:drive/src/modules/statistics/statistics_screen.dart';
import 'package:drive/src/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'src/modules/school_list/school_list.dart';
import 'src/modules/training/training_screen.dart';

class MainHomeScreen extends GetView<MainHomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
          controller: controller.pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(),
            TrainingScreen(),
            // SchoolListScreen(),
            StatisticsScreen(),
            SettingsScreen(),
          ],
          onPageChanged: (page) {
            controller.onPageChanged(page);
          }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          onTap: (newIndex) {
            controller.onBottomIconClick(newIndex);
          },
          currentIndex: pageIndex.value,
          backgroundColor: primaryWhite,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          unselectedItemColor: darkGrey,
          selectedItemColor: tabBarText,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/svg_icons/home.svg',
                    color: pageIndex.value == 0 ? appColor : darkGrey),
                label: currentLanguage['menu_home']),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/svg_icons/clipboard.svg',
                    color: pageIndex.value == 1 ? appColor : darkGrey),
                label: currentLanguage['menu_training']),
            // BottomNavigationBarItem(
            //     icon: SvgPicture.asset('assets/icons/svg_icons/school_list.svg',
            //         height: 20,
            //         width: 20,
            //         color: pageIndex.value == 2 ? appColor : darkGrey),
            //     label: currentLanguage['menu_schools']),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/svg_icons/chart_pie.svg',
                    color: pageIndex.value == 2 ? appColor : darkGrey),
                label: currentLanguage['menu_statistics']),
            BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/icons/svg_icons/settings.svg',
                    color: pageIndex.value == 3 ? appColor : darkGrey),
                label: currentLanguage['menu_settings']),
          ],
        ),
      ),
    );
  }
}
