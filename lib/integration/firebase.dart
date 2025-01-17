import 'package:fanalytics/models/integration.dart';
import 'package:fanalytics/models/track_event.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseIntegration extends Integration {
  const FirebaseIntegration();

  static final firebaseAnalytics = FirebaseAnalytics.instance;

  @override
  Future<void> init({
    String key = '',
    Map<String, dynamic> config = const {},
  }) async {
    await firebaseAnalytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> identify({
    required String userID,
    required Map<String, dynamic> data,
    bool isTheFirstTime = false,
  }) async {
    await firebaseAnalytics.setUserId(
      id: userID,
      callOptions: AnalyticsCallOptions(global: true),
    );

    for (final key in data.keys) {
      firebaseAnalytics.setUserProperty(name: key, value: data[key].toString());
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    final eventProperties = <String, Object>{};

    for (final key in event.properties.keys) {
      eventProperties[key] = event.properties[key].toString();
    }

    switch (event.eventName) {
      case 'Order Completed':
        await firebaseAnalytics.logPurchase(
          parameters: eventProperties,
        );
        break;
      case 'add_to_cart':
        await firebaseAnalytics.logAddToCart(
          parameters: eventProperties,
        );
        break;
      case 'product_removed':
        await firebaseAnalytics.logRemoveFromCart(
          parameters: eventProperties,
        );
        break;
      case 'select_favorite_product':
        await firebaseAnalytics.logAddToWishlist(
          parameters: eventProperties,
        );
        break;
      default:
        await firebaseAnalytics.logEvent(
          name: event.eventName,
          parameters: eventProperties,
        );
    }
  }

  @override
  Future<void> reset() async {
    await firebaseAnalytics.resetAnalyticsData();
  }
}
