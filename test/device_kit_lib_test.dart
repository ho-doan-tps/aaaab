import 'package:flutter_test/flutter_test.dart';
import 'package:device_kit_lib/device_kit_lib.dart';
import 'package:device_kit_lib/device_kit_lib_platform_interface.dart';
import 'package:device_kit_lib/device_kit_lib_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceKitLibPlatform
    with MockPlatformInterfaceMixin
    implements DeviceKitLibPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DeviceKitLibPlatform initialPlatform = DeviceKitLibPlatform.instance;

  test('$MethodChannelDeviceKitLib is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceKitLib>());
  });

  test('getPlatformVersion', () async {
    DeviceKitLib deviceKitLibPlugin = DeviceKitLib();
    MockDeviceKitLibPlatform fakePlatform = MockDeviceKitLibPlatform();
    DeviceKitLibPlatform.instance = fakePlatform;

    expect(await deviceKitLibPlugin.getPlatformVersion(), '42');
  });
}
