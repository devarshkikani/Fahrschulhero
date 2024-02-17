import 'package:flutter/material.dart';
import 'package:get/get.dart';

RxInt pageIndex = 0.obs;

class MainHomeController extends GetxController {
  late PageController pageController;
//= PageController(initialPage: 0)
  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: pageIndex.value);
  }

  void onPageChanged(page) {
    pageIndex.value = page;
    update();
  }

  void onBottomIconClick(newIndex) {
    pageIndex.value = newIndex;
    pageController.animateToPage(newIndex,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
    update();
  }
}
