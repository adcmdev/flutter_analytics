import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fanalytics_method_channel.dart';

abstract class FanalyticsPlatform extends PlatformInterface {
  /// Constructs a FanalyticsPlatform.
  FanalyticsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FanalyticsPlatform _instance = MethodChannelFanalytics();

  /// The default instance of [FanalyticsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFanalytics].
  static FanalyticsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FanalyticsPlatform] when
  /// they register themselves.
  static set instance(FanalyticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
