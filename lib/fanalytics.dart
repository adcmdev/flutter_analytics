import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fanalytics/integration/_integration.dart';
import 'package:fanalytics/models/device.dart';
import 'package:fanalytics/models/event_type.dart';
import 'package:fanalytics/models/integration_init.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A class for managing mobile shared events.
class Fanalytics {
  /// Constructs a [Fanalytics] instance.
  const Fanalytics();

  static Map<String, dynamic> _identifyData = {};
  static Device? _deviceData;

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
    final device = await deviceData;

    data = {
      'ip': await ip,
      'device_ip': device.ip,
      'device_brand': device.brand,
      'device_model': device.model,
      'device_os_version': device.osVersion,
      'device_app_version': device.appVersion,
      'device_platform': device.platform,
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

  static Future<String> get ip async {
    try {
      final ipv4 = await Ipify.ipv4();

      return ipv4;
    } catch (_) {
      return (await _getPublicIP()) ?? '';
    }
  }

  static Future<String?> _getPublicIP() async {
    try {
      final url = Uri.parse('https://api.ipify.org?format=json');
      final response = await HttpClient().getUrl(url).then(
        (req) {
          return req.close();
        },
      );

      if (response.statusCode == 200) {
        final json = await response.transform(utf8.decoder).join();

        return jsonDecode(json)['ip'];
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  static Future<Device> get deviceData async {
    if (_deviceData != null) return _deviceData!;

    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final appVersion = packageInfo.version;
    Map<String, dynamic> result = {};

    final packageInfoData = <String, dynamic>{};

    for (final entry in packageInfo.data.entries) {
      final value = entry.value;

      if (value is DateTime) {
        packageInfoData[entry.key] = value.toIso8601String();
      }

      packageInfoData[entry.key] = value.toString();
    }

    final deviceIP = await ip;

    switch (Platform.operatingSystem) {
      case 'android':
        final androidInfo = await deviceInfoPlugin.androidInfo;

        result = {
          'id': await const AndroidId().getId(),
          'ip': deviceIP,
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'os_version': androidInfo.version.sdkInt.toString(),
          'app_version': appVersion,
          'platform': 'android',
          'data': {
            'device': androidInfo.device,
            'sdk_int': androidInfo.version.sdkInt,
            'is_physical_device': androidInfo.isPhysicalDevice,
            ...packageInfoData,
          },
        };
        break;

      case 'ios':
        final iosInfo = await deviceInfoPlugin.iosInfo;

        result = {
          'id': iosInfo.identifierForVendor,
          'ip': deviceIP,
          'brand': iosInfo.name,
          'model': iosInfo.model,
          'os_version': iosInfo.systemVersion,
          'app_version': appVersion,
          'platform': 'ios',
          'data': {
            'system_name': iosInfo.systemName,
            'is_physical_device': iosInfo.isPhysicalDevice,
            ...packageInfoData,
          },
        };
        break;
      case 'windows':
        final windowsInfo = await deviceInfoPlugin.windowsInfo;

        result = {
          'id': windowsInfo.deviceId,
          'ip': deviceIP,
          'brand': windowsInfo.computerName,
          'model': windowsInfo.displayVersion,
          'os_version': windowsInfo.buildNumber.toString(),
          'app_version': appVersion,
          'platform': 'windows',
          'data': {
            ...packageInfoData,
          },
        };
        break;
      default:
        result = {
          'error': 'OS not supported or not detected',
        };

        break;
    }

    final device = Device.fromMap(result);

    _deviceData = device;
    return device;
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
