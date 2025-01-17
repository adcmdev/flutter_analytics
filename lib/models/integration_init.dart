class FanalyticsIntegrationModel {
  const FanalyticsIntegrationModel({
    this.key = '',
    this.enabled = false,
    this.config = const {},
  });

  final String key;
  final bool enabled;
  final Map<String, dynamic> config;

  factory FanalyticsIntegrationModel.fromJson(Map<String, dynamic> json) {
    return FanalyticsIntegrationModel(
      key: json['key'] ?? '',
      enabled: json['enabled'] ?? false,
      config: json['config'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'enabled': enabled,
      'config': config,
    };
  }
}
