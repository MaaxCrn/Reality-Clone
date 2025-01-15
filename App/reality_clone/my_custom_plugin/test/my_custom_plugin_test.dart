import 'package:flutter_test/flutter_test.dart';
import 'package:my_custom_plugin/my_custom_plugin.dart';
import 'package:my_custom_plugin/my_custom_plugin_platform_interface.dart';
import 'package:my_custom_plugin/my_custom_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyCustomPluginPlatform
    with MockPlatformInterfaceMixin
    implements MyCustomPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyCustomPluginPlatform initialPlatform = MyCustomPluginPlatform.instance;

  test('$MethodChannelMyCustomPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyCustomPlugin>());
  });

  test('getPlatformVersion', () async {
    MyCustomPlugin myCustomPlugin = MyCustomPlugin();
    MockMyCustomPluginPlatform fakePlatform = MockMyCustomPluginPlatform();
    MyCustomPluginPlatform.instance = fakePlatform;

    expect(await myCustomPlugin.getPlatformVersion(), '42');
  });
}
