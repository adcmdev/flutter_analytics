class Device {
  final String id;
  final String ip;
  final String brand;
  final String model;
  final String osVersion;
  final String appVersion;
  final String platform;
  final Map<String, dynamic> data;

  const Device({
    required this.id,
    required this.ip,
    required this.brand,
    required this.model,
    required this.osVersion,
    required this.appVersion,
    required this.platform,
    required this.data,
  });

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] ?? '',
      ip: map['ip'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      osVersion: map['os_version'] ?? '',
      appVersion: map['app_version'] ?? '',
      platform: map['platform'] ?? '',
      data: map['data'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ip': ip,
      'brand': brand,
      'model': model,
      'os_version': osVersion,
      'app_version': appVersion,
      'platform': platform,
      'data': data,
    };
  }
}
