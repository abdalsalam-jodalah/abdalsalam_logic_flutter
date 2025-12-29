class VpnInfo {
  final bool isConnected;
  final String? vpnName;
  final DateTime timestamp;

  const VpnInfo({
    required this.isConnected,
    this.vpnName,
    required this.timestamp,
  });

  factory VpnInfo.initial() => VpnInfo(
        isConnected: false,
        vpnName: null,
        timestamp: DateTime.now(),
      );

  VpnInfo copyWith({
    bool? isConnected,
    String? vpnName,
    DateTime? timestamp,
  }) =>
      VpnInfo(
        isConnected: isConnected ?? this.isConnected,
        vpnName: vpnName ?? this.vpnName,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'isConnected': isConnected,
        'vpnName': vpnName,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'VpnInfo(connected: $isConnected, name: ${vpnName ?? "None"})';
}
