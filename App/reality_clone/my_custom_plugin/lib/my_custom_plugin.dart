import 'package:flutter/services.dart';
import 'my_custom_plugin_platform_interface.dart';

class MyCustomPlugin {
  static const MethodChannel _channel = MethodChannel('my_custom_plugin');

  Future<String?> getPlatformVersion() {
    return MyCustomPluginPlatform.instance.getPlatformVersion();
  }

  static Future<Map<String, double>?> getFocalLengths() async {
    final result = await _channel.invokeMapMethod<String, double>('getFocalLengths');
    return result;
  }
}
