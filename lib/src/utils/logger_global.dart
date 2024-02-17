import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/utils/locator.dart';

class GlobalLogger {
  static Future tryLogToServer(e, {context, logLevel}) async {
    try {
      final NetworkRepository _networkRepository = locator<NetworkRepository>();
      await _networkRepository.log(e.toString(),
          context: context, logLevel: logLevel);
    } catch (e) {}
  }
}
