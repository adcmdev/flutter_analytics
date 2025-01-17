import 'package:fanalytics/integration/firebase.dart';
import 'package:fanalytics/models/integration.dart';
import 'package:fanalytics/models/integration_init.dart';
import 'package:fanalytics/models/track_event.dart';

enum IntegrationsEnum {
  firebase(implementation: FirebaseIntegration());

  const IntegrationsEnum({
    required this.implementation,
  });

  final Integration implementation;
}

class IntegrationFactory {
  static List<IntegrationsEnum> integrations = [];

  static Future<void> init(
      Map<String, FanalyticsIntegrationModel> configMap) async {
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
    required String userID,
    required Map<String, dynamic> identifyData,
    bool isTheFirstTime = false,
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.implementation.identify(
            userID: userID,
            data: identifyData,
            isTheFirstTime: isTheFirstTime,
          ),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> track({
    required TrackEvent event,
  }) async {
    final awaitables = <Future>[];
    for (final integration in integrations) {
      awaitables.add(
        safeExecute(
          () => integration.implementation.track(event: event),
          integration,
        ),
      );
    }

    await Future.wait(awaitables);
  }

  static Future<void> reset() async {
    final awaitables = <Future>[];

    for (final integration in integrations) {
      awaitables
          .add(safeExecute(integration.implementation.reset, integration));
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
