class WiFiInfo {
  final bool isConnected;
  final String? ssid;
  final String? bssid;
  final String? ipAddress;
  final String? gateway;
  final String? subnet;
  final int? signalStrength;
  final int? linkSpeed;
  final int? frequency;
  final String? securityType;
  final DateTime timestamp;

  const WiFiInfo({
    required this.isConnected,
    this.ssid,
    this.bssid,
    this.ipAddress,
    this.gateway,
    this.subnet,
    this.signalStrength,
    this.linkSpeed,
    this.frequency,
    this.securityType,
    required this.timestamp,
  });

  factory WiFiInfo.initial() => WiFiInfo(
        isConnected: false,
        ssid: null,
        bssid: null,
        ipAddress: null,
        gateway: null,
        subnet: null,
        signalStrength: null,
        linkSpeed: null,
        frequency: null,
        securityType: null,
        timestamp: DateTime.now(),
      );

  WiFiInfo copyWith({
    bool? isConnected,
    String? ssid,
    String? bssid,
    String? ipAddress,
    String? gateway,
    String? subnet,
    int? signalStrength,
    int? linkSpeed,
    int? frequency,
    String? securityType,
    DateTime? timestamp,
  }) =>
      WiFiInfo(
        isConnected: isConnected ?? this.isConnected,
        ssid: ssid ?? this.ssid,
        bssid: bssid ?? this.bssid,
        ipAddress: ipAddress ?? this.ipAddress,
        gateway: gateway ?? this.gateway,
        subnet: subnet ?? this.subnet,
        signalStrength: signalStrength ?? this.signalStrength,
        linkSpeed: linkSpeed ?? this.linkSpeed,
        frequency: frequency ?? this.frequency,
        securityType: securityType ?? this.securityType,
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

  String get frequencyBand {
    if (frequency == null) return 'Unknown';
    if (frequency! >= 5000) return '5 GHz';
    if (frequency! >= 2400) return '2.4 GHz';
    return 'Unknown';
  }

  Map<String, dynamic> toMap() => {
        'isConnected': isConnected,
        'ssid': ssid,
        'bssid': bssid,
        'ipAddress': ipAddress,
        'gateway': gateway,
        'subnet': subnet,
        'signalStrength': signalStrength,
        'linkSpeed': linkSpeed,
        'frequency': frequency,
        'frequencyBand': frequencyBand,
        'securityType': securityType,
        'signalQuality': signalQuality,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'WiFiInfo(connected: $isConnected, ssid: $ssid, ip: $ipAddress, signal: $signalQuality)';
}
