import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fanalytics_platform_interface.dart';

/// An implementation of [FanalyticsPlatform] that uses method channels.
class MethodChannelFanalytics extends FanalyticsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fanalytics');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
