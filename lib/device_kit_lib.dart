
import 'device_kit_lib_platform_interface.dart';

class DeviceKitLib {
  Future<String?> getPlatformVersion() {
    return DeviceKitLibPlatform.instance.getPlatformVersion();
  }
}
