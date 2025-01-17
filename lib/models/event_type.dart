import 'package:equatable/equatable.dart';

enum EventType {
  track,
  screen,
  alias;
}

class TrackEvent extends Equatable {
  const TrackEvent({
    required this.eventName,
    this.properties = const {},
    this.eventType = EventType.track,
  });

  final String eventName;
  final EventType eventType;
  final Map<String, dynamic> properties;

  TrackEvent copyWith({
    String? eventName,
    EventType? eventType,
    Map<String, dynamic>? properties,
  }) {
    return TrackEvent(
      eventName: eventName ?? this.eventName,
      eventType: eventType ?? this.eventType,
      properties: properties ?? this.properties,
    );
  }

  @override
  List<Object?> get props {
    return [
      eventName,
      eventType,
      properties,
    ];
  }
}
