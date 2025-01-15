import 'package:flutter/services.dart';
import 'my_custom_plugin_platform_interface.dart';

class MyCustomPlugin {
  static const MethodChannel _channel = MethodChannel('my_custom_plugin');

  Future<String?> getPlatformVersion() {
    return MyCustomPluginPlatform.instance.getPlatformVersion();
  }

  static Future<double> getFocalLength() async {
    final double focalLength = await _channel.invokeMethod('getFocalLength');
    return focalLength;
  }
}
