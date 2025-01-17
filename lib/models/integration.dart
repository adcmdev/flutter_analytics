import 'package:fanalytics/models/track_event.dart';

class Integration {
  const Integration();

  Future<void> init({
    String key = '',
    Map<String, dynamic> config = const {},
  }) async {}

  Future<void> identify({
    required String userID,
    required Map<String, dynamic> data,
    bool isTheFirstTime = false,
  }) async {}

  Future<void> track({
    required TrackEvent event,
  }) async {}

  Future<void> reset() async {}
}
