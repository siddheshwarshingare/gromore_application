import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil {
  static Future<String> getUserAgent(TargetPlatform platform) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release} (${androidInfo.model})';
      } else if (platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'iOS ${iosInfo.systemVersion} (${iosInfo.utsname.machine})';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Error retrieving device info: $e';
    }
  }
}
