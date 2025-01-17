import 'package:fanalytics/fanalytics_platform_interface.dart';
import 'package:fanalytics/integration/_integration.dart';
import 'package:fanalytics/models/integration_init.dart';
import 'package:fanalytics/models/track_event.dart';

/// A class for managing mobile shared events.
class Fanalytics {
  /// Constructs a [Fanalytics] instance.
  Fanalytics({this.identifyData = const {}, this.context = const {}});

  Map<String, dynamic> identifyData;
  Map<String, dynamic> context;

  Future<String?> getPlatformVersion() {
    return FanalyticsPlatform.instance.getPlatformVersion();
  }

  Future<void> init({
    required Map<String, FanalyticsIntegrationModel> configMap,
    required Map<String, dynamic> deviceData,
    required String ip,
  }) async {
    try {
      context = {
        'device': deviceData,
        'ip': ip,
      };

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

    data['Identity'] = id;
    data['identity'] = id;

    final allData = <String, dynamic>{};

    for (final key in data.keys) {
      if (data[key] == null) continue;

      allData[key] = data[key];
    }

    await IntegrationFactory.identify(
      userID: id,
      identifyData: data,
      isTheFirstTime: identifyData.isEmpty,
    );

    identifyData = data;
  }

  void track({
    required TrackEvent trackEvent,
  }) async {
    try {
      final tempData = {...trackEvent.properties};
      tempData.addAll(filterIdentifyData(identifyData));

      await IntegrationFactory.track(
        event: trackEvent.copyWith(
          properties: tempData,
        ),
      );
    } catch (e) {
      return;
    }
  }

  Future<void> reset() async {
    try {
      await IntegrationFactory.reset();
      identifyData = {};
      context = {};
    } catch (e) {
      return;
    }
  }

  Map<String, dynamic> filterIdentifyData(Map<String, dynamic> data) {
    const allowedFields = [
      'identity',
      'city',
      'country',
      'currency',
      'cupotul_available',
      'cupotul_balance',
      'cupotul_payment_available',
      'userId',
      'warehouse_name',
      'channel',
      'email',
      'Email',
      'device_os',
      'device_type',
      'app_type',
      'index',
      'client_uuid',
    ];

    final tempData = <String, dynamic>{};

    for (final key in data.keys) {
      if (allowedFields.contains(key)) {
        tempData[key] = data[key];
      }
    }

    return tempData;
  }
}
