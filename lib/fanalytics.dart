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

    final device = (await deviceData);

    data = {
      'ip': await ip,
      ...flattenMap(device, prefix: 'device'),
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

    final deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> result = {};

    if (kIsWeb) {
      // WEB
      final webInfo = await deviceInfoPlugin.webBrowserInfo;
      result = {
        'browserName': webInfo.browserName.toString(),
        'appVersion': webInfo.appVersion,
        'platform': webInfo.platform,
      };
    } else {
      switch (Platform.operatingSystem) {
        case 'android':
          final androidInfo = await deviceInfoPlugin.androidInfo;
          result = {
            'brand': androidInfo.brand,
            'device': androidInfo.device,
            'model': androidInfo.model,
            'isPhysicalDevice': androidInfo.isPhysicalDevice,
            'sdkInt': androidInfo.version.sdkInt,
            'release': androidInfo.version.release,
          };
          break;

        case 'ios':
          final iosInfo = await deviceInfoPlugin.iosInfo;
          result = {
            'name': iosInfo.name,
            'model': iosInfo.model,
            'systemName': iosInfo.systemName,
            'systemVersion': iosInfo.systemVersion,
            'isPhysicalDevice': iosInfo.isPhysicalDevice,
            'identifierForVendor': iosInfo.identifierForVendor,
          };
          break;

        case 'macos':
          final macOsInfo = await deviceInfoPlugin.macOsInfo;
          result = {
            'computerName': macOsInfo.computerName,
            'hostName': macOsInfo.hostName,
            'arch': macOsInfo.arch,
            'model': macOsInfo.model,
          };
          break;

        case 'linux':
          final linuxInfo = await deviceInfoPlugin.linuxInfo;
          result = {
            'name': linuxInfo.name,
            'version': linuxInfo.version,
            'id': linuxInfo.id,
            'idLike': linuxInfo.idLike,
            'variant': linuxInfo.variant,
          };
          break;

        case 'windows':
          final windowsInfo = await deviceInfoPlugin.windowsInfo;
          result = {
            'computerName': windowsInfo.computerName,
            'numberOfCores': windowsInfo.numberOfCores,
            'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
          };
          break;

        default:
          result = {'error': 'OS not supported or not detected'};
          break;
      }
    }

    _deviceData = result;
    return _deviceData;
  }

  Map<String, dynamic> flattenMap(
    Map<String, dynamic> original, {
    String prefix = '',
  }) {
    final Map<String, dynamic> result = {};

    original.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '${prefix}_$key';

      if (value is Map) {
        result.addAll(
          flattenMap(
            Map<String, dynamic>.from(value),
            prefix: newKey,
          ),
        );
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }
}

extension StringExtension on String {
  String get toSnakeCase {
    final exp = RegExp(r'(?<!^)([A-Z])');

    return replaceAllMapped(exp, (Match m) => '_${m[0]}').toLowerCase();
  }
}
