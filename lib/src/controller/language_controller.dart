import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

RxMap currentLanguage = {}.obs;

class LanguageController extends GetxController {
  GetStorage _getStorage = GetStorage();

  void changeCurrentLanguage(
    String languageCode,
  ) {
    if (_getStorage.read('translation') != null) {
      Map translation = _getStorage.read('translation') as Map;
      if (languageCode == 'en') {
        currentLanguage.value = translation['en'];
      } else {
        currentLanguage.value = translation['de'];
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    changeCurrentLanguage(_getStorage.read('language') ?? 'de');
  }
}
