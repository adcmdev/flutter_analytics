import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';

class UmamiService {
  final String host;
  final String website;
  String? _sessionId;

  UmamiService({
    required this.host,
    required this.website,
  });

  /// Generates a unique session ID.
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000).toRadixString(36);
    return 'session_$random';
  }

  Future<String> getCustomUserAgent() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return 'Mozilla/5.0 (Linux; Android ${androidInfo.version.release}; ${androidInfo.model}) AppleWebKit/537.36 (KHTML, like Gecko) Mobile';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('.', '_')} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile';
    } else {
      return 'FlutterApp/1.0';
    }
  }

  Future<bool> _sendEvent({
    required String title,
    String referrer = '',
    Map<String, dynamic>? data,
    String type = 'event',
  }) async {
    final userAgent = await getCustomUserAgent();
    debugPrint('User-Agent: $userAgent');

    final payload = {
      'payload': {
        'referrer': referrer,
        'title': title,
        'website': website,
        if (data != null) 'data': data,
        if (_sessionId != null) 'sessionId': _sessionId,
      },
      'type': type,
    };

    final dio = Dio();

    try {
      final response = await dio.post(
        '$host/api/websites/$website/events',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': userAgent,
          },
        ),
        data: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending event to Umami: $e');
      return false;
    }
  }

  /// Sends a custom event to Umami.
  ///
  /// [context] is the current [BuildContext].
  /// [title] is the event or page title.
  /// [name] is the event name.
  /// [data] is a map with additional event data (optional).
  Future<void> trackEvent({
    required String title,
    required String name,
    Map<String, dynamic>? data,
  }) async {
    await _sendEvent(
      title: title,
      data: data,
    );
  }

  /// Tracks a page view.
  ///
  /// [title] is the page title.
  /// [url] is the page URL (optional).
  /// [referrer] is the referrer URL (optional).
  /// [data] is a map with additional page data (optional).
  Future<void> trackPageView({
    required String title,
    String? url,
    String? referrer,
    Map<String, dynamic>? data,
  }) async {
    await _sendEvent(
      title: title,
      referrer: referrer ?? '',
      data: data,
      type: 'pageview',
    );
  }

  /// Tracks a screen view (alias for trackPageView for mobile apps).
  ///
  /// [screenName] is the screen name.
  /// [data] is a map with additional screen data (optional).
  Future<void> trackScreen({
    required String screenName,
    Map<String, dynamic>? data,
  }) async {
    await trackPageView(
      title: screenName,
      data: data,
    );
  }

  /// Identifies a user session with a unique ID.
  ///
  /// [userId] is a unique identifier for the user.
  /// [data] is a map with additional user data (optional).
  Future<void> identify({
    String? userId,
    Map<String, dynamic>? data,
  }) async {
    _sessionId = userId ?? _generateSessionId();

    final identifyData = <String, dynamic>{};
    if (_sessionId != null) {
      identifyData['userId'] = _sessionId!;
    }
    if (data != null) {
      identifyData.addAll(data);
    }

    await _sendEvent(
      title: 'identify',
      data: identifyData,
      type: 'identify',
    );
  }

  /// Sets user properties for the current session.
  ///
  /// [properties] is a map with user properties.
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    await _sendEvent(
      title: 'user_properties',
      data: properties,
      type: 'user_properties',
    );
  }

  /// Resets the current session and clears stored user data.
  Future<void> reset() async {
    _sessionId = null;
    await _sendEvent(
      title: 'reset',
      type: 'reset',
    );
  }

  /// Tracks when a user session starts.
  ///
  /// [data] is a map with additional session data (optional).
  Future<void> startSession({Map<String, dynamic>? data}) async {
    if (_sessionId == null) {
      _sessionId = _generateSessionId();
    }

    await _sendEvent(
      title: 'session_start',
      data: data,
      type: 'session_start',
    );
  }

  /// Tracks when a user session ends.
  ///
  /// [data] is a map with additional session data (optional).
  Future<void> endSession({Map<String, dynamic>? data}) async {
    await _sendEvent(
      title: 'session_end',
      data: data,
      type: 'session_end',
    );
    _sessionId = null;
  }

  /// Generic track method that can be used for custom tracking.
  ///
  /// [eventName] is the name of the event (optional, if null treats as pageview).
  /// [properties] is a map with event properties (optional).
  Future<void> track({
    String? eventName,
    Map<String, dynamic>? properties,
  }) async {
    if (eventName != null) {
      // Custom event
      await _sendEvent(
        title: eventName,
        data: properties,
        type: 'event',
      );
    } else {
      // Pageview with custom properties
      await _sendEvent(
        title: properties?['title'] ?? 'Page View',
        referrer: properties?['referrer'] ?? '',
        data: properties,
        type: 'pageview',
      );
    }
  }

  /// Gets the current session ID.
  String? get sessionId => _sessionId;
}
