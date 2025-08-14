import 'package:fanalytics/fanalytics.dart';
import 'package:flutter/widgets.dart';

class FanalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final Fanalytics fanalytics;
  FanalyticsRouteObserver({
    required this.fanalytics,
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    _addBreadcrumb(
      type: 'didPush',
      from: previousRoute?.settings,
      to: route.settings,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    _addBreadcrumb(
      type: 'didPop',
      from: route.settings,
      to: previousRoute?.settings,
    );
  }

  void _addBreadcrumb({
    required String type,
    RouteSettings? from,
    RouteSettings? to,
  }) {
    try {
      fanalytics.screen(
        toRoute: to,
        previousRoute: from,
      );
    } catch (_) {}
  }
}
