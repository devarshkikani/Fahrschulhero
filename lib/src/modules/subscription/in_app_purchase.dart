import 'dart:async';
import 'dart:io';
import 'package:drive/src/controller/home_controller.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:drive/src/utils/process_indicator.dart';
import 'package:drive/src/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_ios/store_kit_wrappers.dart';
import 'package:in_app_purchase_ios/in_app_purchase_ios.dart';

const bool _kAutoConsume = true;
String lifeTimeSubscription =
    Platform.isAndroid ? 'one_time_subscription' : 'life_time_subscription';
const String weekly_subscription = 'weekly_subscription';
List<String> _kProductIds = <String>[
  lifeTimeSubscription,
  weekly_subscription,
];

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // final NetworkRepository _networkRepository = locator<NetworkRepository>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  NetworkRepository networkRepository = locator<NetworkRepository>();
  RxString pricePerWeek = ''.obs;
  RxString pricePerLife = ''.obs;
  Circle processIndicator = Circle();

  @override
  void initState() {
    getPricePerWeek();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription.cancel();
        if (processIndicator.isShow && mounted) processIndicator.hide(context);
      },
      cancelOnError: true,
      onError: (error) {
        if (processIndicator.isShow && mounted) processIndicator.hide(context);
      },
    );
    initStoreInfo();
    super.initState();
  }

  Future<void> getPricePerWeek() async {
    Map<String, dynamic> getPricePerWeek =
        await networkRepository.getPricePerWeek(context);
    pricePerWeek.value = getPricePerWeek['data'].toString();
    getPricePerLife();
  }

  Future<void> getPricePerLife() async {
    Map<String, dynamic> getPricePerLife =
        await networkRepository.getPricePerLife(context);
    pricePerLife.value = getPricePerLife['data'].toString();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();

    if (!isAvailable) {
      setState(() {
        _products = [];
        _purchases = [];
      });
      return;
    }

    if (Platform.isIOS) {
      InAppPurchaseIosPlatformAddition iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseIosPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());

    setState(() {
      _products = productDetailResponse.productDetails;
      _purchases = [];
    });
    print(_products[0].id.toString());
    print(_products[0].price.toString());
    print(_products[0].rawPrice.toString());
    print(_products.toString());
    print(_products[1].id.toString());
    print(_products[1].price.toString());
    print(_products[1].rawPrice.toString());
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      InAppPurchaseIosPlatformAddition iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseIosPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/subscription_top.jpg',
                  width: Get.width,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 30.0,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 30,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  child: Container(
                    height: 160,
                    width: Get.width,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryWhite.withOpacity(0.01), primaryWhite],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Obx(() => TextAndStyle(
                            title: currentLanguage['plus_firstTitle'],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: appColor,
                          )),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              child: Obx(() => TextAndStyle(
                    title: currentLanguage['plus_firstSubtitle'],
                    color: blackColor,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            Obx(
              () => ListView.builder(
                itemCount: currentLanguage['plus_featuresList']
                    .toString()
                    .split("|")
                    .length,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  List stringData = currentLanguage['plus_featuresList']
                      .toString()
                      .split("|");
                  return benefitsDecoration(stringData[index]);
                },
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: TextAndStyle(
                  title: subscriptionTitle(),
                  color: appColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            becomeProButton(context),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Obx(() => TextAndStyle(
                    title: currentLanguage['plus_secondTitle'],
                    color: blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(() => TextAndStyle(
                    title: currentLanguage['plus_firstText'],
                    color: appColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Image.asset(
                          'assets/images/subscription_center2.jpg',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 4,
                        child: Image.asset(
                          'assets/images/subscription_center1.jpg',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: -25,
                    right: 30,
                    child: Container(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        'assets/images/logo_png.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(() => TextAndStyle(
                    title: currentLanguage['plus_secondSubtitle'],
                    color: textGrey,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                  )),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: TextAndStyle(
                  title: subscriptionTitle(),
                  color: appColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            becomeProButton(context),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  String subscriptionTitle() {
    String addWeekPrice = currentLanguage['plus_offerTitle']
        .toString()
        .replaceAll('{0}', pricePerWeek.value);
    String addLifePrice =
        addWeekPrice.toString().replaceAll('{1}', pricePerLife.value);
    return addLifePrice;
  }

  Widget becomeProButton(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            showBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: appColor,
            ),
            child: Obx(() => TextAndStyle(
                  title: currentLanguage['plus_btnBuy1'],
                  fontFamily: 'Rubik',
                  letterSpacing: 0.2,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: primaryWhite,
                )),
          ),
        ),
      ],
    );
  }

  Widget benefitsDecoration(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: Row(
        children: [
          Icon(
            Icons.star_border_rounded,
            color: appColor,
          ),
          SizedBox(
            width: 7,
          ),
          TextAndStyle(
            title: title,
            fontSize: 14,
            color: textGrey,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget descriptionCommon(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_sharp,
            color: appColor,
            size: 14,
          ),
          SizedBox(
            width: 8.0,
          ),
          TextAndStyle(
            title: description,
            color: textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  void showBottomSheet(BuildContext buildContext) {
    Get.bottomSheet(
      Container(
        height: 320,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 53,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 28, right: 28),
                margin: EdgeInsets.fromLTRB(0, 12, 0, 18),
                decoration: BoxDecoration(
                    color: blackColor, borderRadius: BorderRadius.circular(4)),
              ),
              SizedBox(
                height: 30,
              ),
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextAndStyle(
                        title: subscriptionTitle(),
                        color: appColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      TextAndStyle(
                        title: currentLanguage['plus_offerSubtitle'],
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: () async {
                      processIndicator.show(buildContext);
                      await weeklyPlan(buildContext);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(color: yellowColor, width: 2),
                        color: appColor,
                      ),
                      child: TextAndStyle(
                        title: currentLanguage['btn_pricePerWeek']
                            .toString()
                            .replaceAll('{0}', pricePerWeek.value),
                        fontFamily: 'Rubik',
                        letterSpacing: 0.2,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: primaryWhite,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      processIndicator.show(buildContext);
                      await lifeTimePurchase(buildContext);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(color: yellowColor, width: 2),
                        color: appColor,
                      ),
                      child: TextAndStyle(
                        title: currentLanguage['btn_pricePerLife']
                            .toString()
                            .replaceAll('{0}', pricePerLife.value),
                        fontFamily: 'Rubik',
                        letterSpacing: 0.2,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: primaryWhite,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Obx(() => TextAndStyle(
                    title: offerText(),
                    fontSize: 10.0,
                    fontWeight: FontWeight.w400,
                    color: textGrey,
                  )),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      backgroundColor: whiteColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
    );
  }

  Future<void> weeklyPlan(buildContext) async {
    Map<String, PurchaseDetails> purchases = Map.fromEntries(
      _purchases.map(
        (PurchaseDetails purchase) {
          if (purchase.pendingCompletePurchase) {
            _inAppPurchase.completePurchase(purchase);
          }
          return MapEntry<String, PurchaseDetails>(
              purchase.productID, purchase);
        },
      ),
    );
    late PurchaseParam purchaseParam;
    if (_products.isNotEmpty) {
      if (Platform.isAndroid) {
        final oldSubscription = _getOldSubscription(_products[1], purchases);

        purchaseParam = GooglePlayPurchaseParam(
            productDetails: _products[1],
            applicationUserName: GetStorage().read('userId'),
            changeSubscriptionParam: (oldSubscription != null)
                ? ChangeSubscriptionParam(
                    oldPurchaseDetails: oldSubscription,
                    prorationMode: ProrationMode.immediateWithTimeProration,
                  )
                : null);
      } else {
        purchaseParam = PurchaseParam(
          productDetails: _products[1],
        );
      }
      if (Platform.isIOS) {
        List<SKPaymentTransactionWrapper> transactions =
            await SKPaymentQueueWrapper().transactions();
        transactions.forEach((skPaymentTransactionWrapper) {
          SKPaymentQueueWrapper()
              .finishTransaction(skPaymentTransactionWrapper);
        });
      }
      try {
        await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } on PlatformException catch (e) {
        inAppPurchaseErrorHandle(buildContext, e.message.toString());
      } on Exception catch (e) {
        inAppPurchaseErrorHandle(buildContext, e.toString());
      }
    } else {
      showSnackBar(
        title: currentLanguage['modal_oopsTitle'],
        message: currentLanguage['subs_errorAppStoreText'],
        colorText: whiteColor,
      );
      if (processIndicator.isShow && mounted) {
        processIndicator.hide(buildContext);
      }
    }
  }

  Future<void> lifeTimePurchase(buildContext) async {
    Map<String, PurchaseDetails> purchases =
        Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    late PurchaseParam purchaseParam;
    if (_products.isNotEmpty) {
      if (Platform.isAndroid) {
        final oldSubscription = _getOldSubscription(_products.first, purchases);

        purchaseParam = GooglePlayPurchaseParam(
            productDetails: _products.first,
            applicationUserName: GetStorage().read('userId'),
            changeSubscriptionParam: (oldSubscription != null)
                ? ChangeSubscriptionParam(
                    oldPurchaseDetails: oldSubscription,
                    prorationMode: ProrationMode.immediateWithTimeProration,
                  )
                : null);
      } else {
        purchaseParam = PurchaseParam(
          productDetails: _products.first,
        );
      }
      if (Platform.isIOS) {
        var transactions = await SKPaymentQueueWrapper().transactions();
        transactions.forEach((skPaymentTransactionWrapper) {
          SKPaymentQueueWrapper()
              .finishTransaction(skPaymentTransactionWrapper);
        });
      }
      try {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } on PlatformException catch (e) {
        inAppPurchaseErrorHandle(buildContext, e.message.toString());
      } on Exception catch (e) {
        inAppPurchaseErrorHandle(buildContext, e.toString());
      }
    } else {
      showSnackBar(
        title: currentLanguage['modal_oopsTitle'],
        message: currentLanguage['subs_errorAppStoreText'],
        colorText: whiteColor,
      );
      if (processIndicator.isShow && mounted) {
        processIndicator.hide(buildContext);
      }
    }
  }

  void inAppPurchaseErrorHandle(BuildContext buildContext, String message) {
    if (processIndicator.isShow && mounted) {
      processIndicator.hide(buildContext);
    }
    showSnackBar(
      title: currentLanguage['modal_oopsTitle'],
      message: currentLanguage['subs_errorAppStoreText'],
      colorText: whiteColor,
    );
  }

  String offerText() {
    String addWeekPrice = currentLanguage['plus_offerText']
        .toString()
        .replaceAll('{0}', pricePerWeek.value);
    String addLifePrice =
        addWeekPrice.toString().replaceAll('{1}', pricePerLife.value);
    return addLifePrice;
  }

  Future<void> successPurchase() async {
    // Future.delayed(Duration(seconds: 2), () async {
    //   await getUser(null);
    // });
    if (processIndicator.isShow && mounted) processIndicator.hide(context);
    Get.find<HomeController>().isSubscribe.value = true;
    GetStorage().write('isSubscribe', true);
    Get.back();
    Get.back();
    showSnackBar(
      title: currentLanguage['noti_congratsSubTitle'],
      message: currentLanguage['noti_congratsSubSubtitle'],
      colorText: whiteColor,
    );
  }

  void handleError(IAPError error) {
    if (processIndicator.isShow && mounted) processIndicator.hide(context);

    if (Platform.isAndroid) {
      if (error.message != 'BillingResponse.userCanceled') {
        showSnackBar(
            title: currentLanguage['modal_oopsTitle'],
            message: currentLanguage['subs_errorAppStoreText'],
            colorText: whiteColor,
            backgroundColor: redColor);
      }
    } else {
      if (error.message != 'SKErrorDomain') {
        showSnackBar(
            title: currentLanguage['modal_oopsTitle'],
            message: currentLanguage['subs_errorAppStoreText'],
            colorText: whiteColor,
            backgroundColor: redColor);
      }
    }
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print({
        'error': purchaseDetails.error,
        'purchaseID': purchaseDetails.purchaseID,
        'status': purchaseDetails.status,
        'serverVerificationData':
            purchaseDetails.verificationData.serverVerificationData,
      });
      if (purchaseDetails.status == PurchaseStatus.error) {
        handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        deliverProduct(purchaseDetails);
      }
      if (Platform.isAndroid) {
        if (!_kAutoConsume &&
            purchaseDetails.productID == lifeTimeSubscription) {
          final InAppPurchaseAndroidPlatformAddition androidAddition =
              _inAppPurchase
                  .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          await androidAddition.consumePurchase(purchaseDetails);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == lifeTimeSubscription) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
    } else {
      _purchases.add(purchaseDetails);
    }

    if (Platform.isIOS) {
      final Map<String, dynamic>? response =
          await networkRepository.buyAppStore(
        null,
        {
          'serverVerificationData':
              purchaseDetails.verificationData.serverVerificationData
        },
      );
      if (response != null) {
        if (response['statusCode'] == 200) {
          await successPurchase();
        }
      }
    } else {
      final Map<String, dynamic>? response =
          await networkRepository.buyPlayStore(
        context,
        {
          'productId': purchaseDetails.productID,
          'token': purchaseDetails.verificationData.serverVerificationData
        },
      );
      if (response != null) {
        if (response['statusCode'] == 200) {
          await successPurchase();
        }
      }
    }
    if (mounted) setState(() {});
  }

  // getUser(BuildContext? context) async {
  //   final response = await _networkRepository.getUserDetails(null);
  //   if (response != null) {
  //     if (response['statusCode'] == 200) {
  //       if (response['data']['expiresSubscription'] != null) {
  //         DateTime expiresSubscription =
  //             DateTime.parse(response['data']['expiresSubscription']).toUtc();
  //         DateTime now = DateTime.now().toUtc();
  //         Duration duration = now.difference(expiresSubscription);
  //         if (duration.isNegative) {
  //           Get.find<HomeController>().isSubscribe.value = true;
  //           GetStorage().write('isSubscribe', true);
  //           Get.back();
  //         } else {
  //           Get.find<HomeController>().isSubscribe.value = false;
  //           GetStorage().write('isSubscribe', false);
  //         }
  //       } else {
  //         Get.find<HomeController>().isSubscribe.value = false;
  //         GetStorage().write('isSubscribe', false);
  //       }
  //     }
  //   }
  // }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == lifeTimeSubscription &&
        purchases[weekly_subscription] != null) {
      oldSubscription =
          purchases[weekly_subscription] as GooglePlayPurchaseDetails;
    } else if (productDetails.id == weekly_subscription &&
        purchases[lifeTimeSubscription] != null) {
      oldSubscription =
          purchases[lifeTimeSubscription] as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

class ConsumableStore {
  static const String _kPrefKey = 'consumables';
  static Future<void> _writes = Future.value();
  static Future<void> save(String id) {
    _writes = _writes.then((void _) => _doSave(id));
    return _writes;
  }

  static Future<void> consume(String id) {
    _writes = _writes.then((void _) => _doConsume(id));
    return _writes;
  }

  static List<dynamic> load() {
    return GetStorage().read(_kPrefKey) ?? [];
  }

  static void _doSave(String id) {
    List<dynamic> cached = load();
    cached.add(id);
    GetStorage().write(_kPrefKey, cached);
  }

  static void _doConsume(String id) {
    List<dynamic> cached = load();
    cached.remove(id);
    GetStorage().write(_kPrefKey, cached);
  }
}
