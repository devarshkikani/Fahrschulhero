import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChangeLanguage extends StatefulWidget {
  ChangeLanguage({Key? key}) : super(key: key);

  @override
  State<ChangeLanguage> createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  LanguageController languageController = Get.put(LanguageController());
  RxString selectedId = ''.obs;
  RxString dropdownvalue = 'German'.obs;
  GetStorage getStorage = GetStorage();
  var items = [
    'German',
    'English',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dropdownvalue.value = getStorage.read("language") != null
        ? getStorage.read("language") != 'en'
            ? 'German'
            : 'English'
        : 'German';

    getStorage.write(
        'language', dropdownvalue.value == 'English' ? 'en' : 'du');
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      padding: EdgeInsets.fromLTRB(11, 0, 11, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: appColor.withOpacity(0.1),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton(
            value: dropdownvalue.value,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: tabBarText,
            ),
            items: items.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/flag/$items.png',
                      height: 35,
                      width: 35,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              dropdownvalue.value = value!;
              if (value == "German") {
                languageController.changeCurrentLanguage('du');
                getStorage.write('language', 'du');
              } else {
                languageController.changeCurrentLanguage('en');
                getStorage.write('language', 'en');
              }
            },
          ),
        ),
      ),
    );
  }
}
