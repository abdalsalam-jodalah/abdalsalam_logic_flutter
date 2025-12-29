class WiFiInfo {
  final bool isConnected;
  final String? ssid;
  final String? bssid;
  final int? signalStrength;
  final DateTime timestamp;

  const WiFiInfo({
    required this.isConnected,
    this.ssid,
    this.bssid,
    this.signalStrength,
    required this.timestamp,
  });

  factory WiFiInfo.initial() => WiFiInfo(
        isConnected: false,
        ssid: null,
        bssid: null,
        signalStrength: null,
        timestamp: DateTime.now(),
      );

  WiFiInfo copyWith({
    bool? isConnected,
    String? ssid,
    String? bssid,
    int? signalStrength,
    DateTime? timestamp,
  }) =>
      WiFiInfo(
        isConnected: isConnected ?? this.isConnected,
        ssid: ssid ?? this.ssid,
        bssid: bssid ?? this.bssid,
        signalStrength: signalStrength ?? this.signalStrength,
        timestamp: timestamp ?? this.timestamp,
      );

  String get signalQuality {
    if (!isConnected) return 'Disconnected';
    final strength = signalStrength ?? 0;
    if (strength > -50) return 'Excellent';
    if (strength > -60) return 'Very Good';
    if (strength > -70) return 'Good';
    if (strength > -80) return 'Fair';
    return 'Poor';
  }

  Map<String, dynamic> toMap() => {
        'isConnected': isConnected,
        'ssid': ssid,
        'bssid': bssid,
        'signalStrength': signalStrength,
        'signalQuality': signalQuality,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'WiFiInfo(connected: $isConnected, ssid: $ssid, signal: $signalQuality)';
}
