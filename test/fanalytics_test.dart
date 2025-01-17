import 'package:flutter_test/flutter_test.dart';
import 'package:fanalytics/fanalytics.dart';
import 'package:fanalytics/fanalytics_platform_interface.dart';
import 'package:fanalytics/fanalytics_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFanalyticsPlatform
    with MockPlatformInterfaceMixin
    implements FanalyticsPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FanalyticsPlatform initialPlatform = FanalyticsPlatform.instance;

  test('$MethodChannelFanalytics is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFanalytics>());
  });

  test('getPlatformVersion', () async {
    Fanalytics fanalyticsPlugin = Fanalytics();
    MockFanalyticsPlatform fakePlatform = MockFanalyticsPlatform();
    FanalyticsPlatform.instance = fakePlatform;

    expect(await fanalyticsPlugin.getPlatformVersion(), '42');
  });
}
