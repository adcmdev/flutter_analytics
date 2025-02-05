import 'package:fanalytics/models/event_type.dart';

class Integration {
  const Integration();

  Future<void> init({
    String key = '',
    Map<String, dynamic> config = const {},
  }) async {}

  Future<void> identify({
    required String id,
    required Map<String, dynamic> data,
  }) async {}

  Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {}

  Future<void> reset() async {}
}
