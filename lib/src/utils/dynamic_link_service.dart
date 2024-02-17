import 'package:get_storage/get_storage.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicRepository {
  GetStorage getStorage = GetStorage();

  Future<Uri> createDynamicLink(String uid) async {
    String uriPrefix = "https://fahrschulhero.page.link";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: Uri.parse('https://fahrschulhero.de?Invite=$uid'),
      androidParameters: AndroidParameters(
        packageName: 'com.Fahrschulhero',
        minimumVersion: 125,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.Fahrschulhero',
        minimumVersion: '1.0.0',
        appStoreId: '1599075528',
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
    );
    Uri dynamicUrl = await parameters.buildUrl();
    return dynamicUrl;
  }

  Future<void> initDynamicLinks() async {
    PendingDynamicLinkData? dynamicLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    print("${dynamicLink?.link}" + '++++++++');
    if (dynamicLink != null) {
      await onSuccessLink(dynamicLink);
    }
  }

  Future<void> onSuccessLink(
    PendingDynamicLinkData? dynamicLink,
  ) async {
    if (dynamicLink != null) {
      String? query = dynamicLink.link.query;
      if (query.contains('Invite=')) {
        String invitationToken = query.split('=')[1];
        getStorage.write('invitationToken', invitationToken);
      }
    }
  }
}
