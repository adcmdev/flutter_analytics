import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fanalytics/integration/_integration.dart';
import 'package:fanalytics/models/event_type.dart';
import 'package:fanalytics/models/integration_init.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  static Future<Map<String, dynamic>> get deviceData async {
    if (_deviceData.isNotEmpty) return _deviceData;

    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final appVersion = packageInfo.version;
    Map<String, dynamic> result = {};

    switch (Platform.operatingSystem) {
      case 'android':
        final androidInfo = await deviceInfoPlugin.androidInfo;

        result = {
          'id': androidInfo.id,
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'os_version': androidInfo.version.sdkInt.toString(),
          'app_version': appVersion,
          'platform': 'android',
          'data': {
            'device': androidInfo.device,
            'sdk_int': androidInfo.version.sdkInt,
            'is_physical_device': androidInfo.isPhysicalDevice,
            ...packageInfo.data,
          },
        };
        break;

      case 'ios':
        final iosInfo = await deviceInfoPlugin.iosInfo;

        result = {
          'id': iosInfo.identifierForVendor,
          'brand': iosInfo.name,
          'model': iosInfo.model,
          'os_version': iosInfo.systemVersion,
          'app_version': appVersion,
          'platform': 'ios',
          'data': {
            'system_name': iosInfo.systemName,
            'is_physical_device': iosInfo.isPhysicalDevice,
            ...packageInfo.data,
          },
        };
        break;
      default:
        result = {
          'error': 'OS not supported or not detected',
        };

        break;
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
