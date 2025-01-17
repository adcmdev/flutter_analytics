import 'package:equatable/equatable.dart';

class TrackEvent extends Equatable {
  const TrackEvent({
    required this.eventName,
    this.properties = const {},
    this.eventType = 'click',
  });

  final String eventName;
  final Map<String, dynamic> properties;
  final String eventType;

  TrackEvent copyWith({
    String? eventName,
    Map<String, dynamic>? properties,
    String? eventType,
  }) {
    return TrackEvent(
      eventName: eventName ?? this.eventName,
      properties: properties ?? this.properties,
      eventType: eventType ?? this.eventType,
    );
  }

  factory TrackEvent.fromJson(Map<String, dynamic> json) {
    return TrackEvent(
      eventName: json['event_name'] ?? '',
      properties: json['properties'] ?? '',
      eventType: json['event_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'properties': properties,
      'event_type': eventType,
    };
  }

  @override
  List<Object?> get props {
    return [
      eventName,
      properties,
      eventType,
    ];
  }
}
