// lib/src/app_state/models/network_info.dart
enum NetworkType { wifi, mobile, ethernet, bluetooth, vpn, none, unknown }

enum MobileNetworkType { unknown, g2, g3, g4, g5 }

class NetworkInfo {
  final NetworkType type;
  final MobileNetworkType? mobileType;
  final bool isOnline;
  final DateTime timestamp;

  const NetworkInfo({
    required this.type,
    this.mobileType,
    required this.isOnline,
    required this.timestamp,
  });

  bool get isWifi => type == NetworkType.wifi;
  bool get isMobile => type == NetworkType.mobile;
  bool get isEthernet => type == NetworkType.ethernet;
  bool get isFastConnection =>
      isWifi ||
      isEthernet ||
      (isMobile &&
          mobileType != null &&
          (mobileType == MobileNetworkType.g4 ||
              mobileType == MobileNetworkType.g5));

  NetworkInfo copyWith({
    NetworkType? type,
    MobileNetworkType? mobileType,
    bool? isOnline,
    DateTime? timestamp,
  }) {
    return NetworkInfo(
      type: type ?? this.type,
      mobileType: mobileType ?? this.mobileType,
      isOnline: isOnline ?? this.isOnline,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'mobileType': mobileType?.name,
      'isOnline': isOnline,
      'isWifi': isWifi,
      'isMobile': isMobile,
      'isEthernet': isEthernet,
      'isFastConnection': isFastConnection,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
