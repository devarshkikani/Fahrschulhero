class GlobalSingleton {
  static final GlobalSingleton globalSingleton = GlobalSingleton._internal();

  factory GlobalSingleton() {
    return globalSingleton;
  }

  GlobalSingleton._internal();

  final String appVersion = '3.6';
  int adsSeconds = 10;
  int interstitialAdPage = 4;
  String? deviceToken;
  bool initialRedirect = true;
  Map? translations = Map();
  double? latitude;
  double? longitude;
}
