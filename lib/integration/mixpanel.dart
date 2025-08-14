import 'package:fanalytics/models/event_type.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '_integration.dart';

class MixpanelIntegration extends Integration {
  const MixpanelIntegration();

  static Mixpanel? mixpanel;
  static People? people;

  @override
  Future<void> init({
    String key = '',
    Map<String, dynamic> config = const {},
  }) async {
    mixpanel = await Mixpanel.init(
      key,
      trackAutomaticEvents: false,
    );

    people = mixpanel?.getPeople();

    mixpanel?.setLoggingEnabled(false);
  }

  @override
  Future<void> identify({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    people?.deleteUser();
    await mixpanel?.clearSuperProperties();

    final currentDistinctID = await mixpanel?.getDistinctId() ?? '';

    mixpanel?.alias(id, currentDistinctID);
    await mixpanel?.identify(id);

    people = mixpanel?.getPeople();

    const unknown = 'unknown';

    final customData = {...data};

    for (final key in customData.keys) {
      final value = customData[key];

      if (value == null) continue;
      if (value == '') continue;
      if (value == unknown) continue;

      people?.unset(key);
      people?.set(key, value.toString());
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    await mixpanel?.flush();
  }

  @override
  Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {
    await mixpanel?.track(
      eventName,
      properties: properties.map((key, value) {
        if (value == null || value == '') {
          return MapEntry(key, 'unknown');
        }

        return MapEntry(key, value.toString());
      }),
    );
  }

  @override
  Future<void> reset() async {
    await mixpanel?.flush();
    await mixpanel?.reset();
  }
}
