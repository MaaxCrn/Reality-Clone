import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'my_custom_plugin_platform_interface.dart';

/// An implementation of [MyCustomPluginPlatform] that uses method channels.
class MethodChannelMyCustomPlugin extends MyCustomPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('my_custom_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
