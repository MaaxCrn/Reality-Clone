import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'my_custom_plugin_method_channel.dart';

abstract class MyCustomPluginPlatform extends PlatformInterface {
  /// Constructs a MyCustomPluginPlatform.
  MyCustomPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MyCustomPluginPlatform _instance = MethodChannelMyCustomPlugin();

  /// The default instance of [MyCustomPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelMyCustomPlugin].
  static MyCustomPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MyCustomPluginPlatform] when
  /// they register themselves.
  static set instance(MyCustomPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
