import 'package:fanalytics/integration/firebase.dart';
import 'package:fanalytics/integration/mixpanel.dart';
import 'package:fanalytics/models/event_type.dart';
import 'package:fanalytics/models/integration.dart';
import 'package:fanalytics/models/integration_init.dart';
import 'package:flutter/widgets.dart';

export 'package:fanalytics/models/integration.dart';

enum IntegrationsEnum {
  firebase(implementation: FirebaseIntegration()),
  mixpanel(implementation: MixpanelIntegration());

  const IntegrationsEnum({
    required this.implementation,
  });

  final Integration implementation;
}

class IntegrationFactory {
  static List<IntegrationsEnum> integrations = [];

  static Future<void> init(
    Map<String, FanalyticsIntegrationModel> configMap,
  ) async {
    final awaitables = <Future>[];

    for (final integration in IntegrationsEnum.values) {
      final initModel = configMap[integration.name];

      if (initModel == null) continue;

      if (!initModel.enabled) continue;

      integrations.add(integration);

      final key = initModel.key;

      awaitables.add(
        safeExecute(
          () => integration.implementation.init(
            key: key,
            config: initModel.config,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> identify({
    required String id,
    required Map<String, dynamic> identifyData,
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.implementation.identify(
            id: id,
            data: identifyData,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.implementation.track(
            eventName: eventName,
            eventType: eventType,
            properties: properties,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> reset() async {
    final awaitables = <Future>[];

    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          integration.implementation.reset,
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> screen({
    required RouteSettings? toRoute,
    required RouteSettings? previousRoute,
  }) async {
    final awaitables = <Future>[];

    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.implementation.screen(
            toRoute: toRoute,
            previousRoute: previousRoute,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> safeExecute(
    Function function,
    IntegrationsEnum integration,
  ) async {
    try {
      await function();
    } catch (e) {
      return;
    }
  }
}
