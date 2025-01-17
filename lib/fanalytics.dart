import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fanalytics/integration/_integration.dart';
import 'package:fanalytics/models/event_type.dart';
import 'package:fanalytics/models/integration_init.dart';
import 'package:flutter/foundation.dart';

/// A class for managing mobile shared events.
class Fanalytics {
  /// Constructs a [Fanalytics] instance.
  const Fanalytics();

  static Map<String, dynamic> _identifyData = {};
  static Map<String, dynamic> _deviceData = {};

  Future<void> init({
    required Map<String, FanalyticsIntegrationModel> configMap,
  }) async {
    try {
      await IntegrationFactory.init(configMap);
    } catch (e) {
      return;
    }
  }

  Future<void> identify({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    if (id.isEmpty) return;

    data = {
      'ip': await ip,
      'device': await deviceData,
      ...data,
    };

    await IntegrationFactory.identify(
      id: id,
      identifyData: data,
    );

    _identifyData = data;
  }

  void track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {
    try {
      final tempData = {
        ..._identifyData,
        ...properties,
      };

      await IntegrationFactory.track(
        eventName: eventName,
        eventType: eventType,
        properties: tempData,
      );
    } catch (e) {
      return;
    }
  }

  Future<void> reset() async {
    try {
      await IntegrationFactory.reset();
      _identifyData = {};
    } catch (e) {
      return;
    }
  }

  Future<String> get ip async {
    final ipv4 = await Ipify.ipv4();

    return ipv4;
  }

  Future<Map<String, dynamic>> get deviceData async {
    if (_deviceData.isNotEmpty) return _deviceData;

    var result = <String, dynamic>{};

    switch (Platform.operatingSystem) {
      case 'android':
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        result = androidInfo.data;
        break;
      case 'ios':
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        result = iosInfo.data;
        break;
      case 'macos':
        final macOsInfo = await DeviceInfoPlugin().macOsInfo;
        result = macOsInfo.data;
        break;
      case 'linux':
        final linuxInfo = await DeviceInfoPlugin().linuxInfo;
        result = linuxInfo.data;
        break;
      case 'windows':
        final windowsInfo = await DeviceInfoPlugin().windowsInfo;
        result = windowsInfo.data;
        break;
    }

    if (kIsWeb) {
      final webInfo = await DeviceInfoPlugin().webBrowserInfo;
      result = webInfo.data;
    }

    result = result.map((key, value) {
      return MapEntry(key.toSnakeCase, value);
    });

    _deviceData = result;

    return result;
  }
}

extension StringExtension on String {
  String get toSnakeCase {
    final exp = RegExp(r'(?<!^)([A-Z])');

    return replaceAllMapped(exp, (Match m) => '_${m[0]}').toLowerCase();
  }
}
