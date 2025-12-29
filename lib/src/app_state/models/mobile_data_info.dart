// lib/src/app_state/models/mobile_data_info.dart

enum MobileDataType { none, cellular2g, cellular3g, cellular4g, cellular5g, unknown }

class MobileDataInfo {
  final bool isConnected;
  final MobileDataType dataType;
  final int? signalStrength;
  final String? operatorName;
  final String? isoCountryCode;
  final String? mobileNetworkCode;
  final String? mobileCountryCode;
  final DateTime timestamp;

  const MobileDataInfo({
    required this.isConnected,
    required this.dataType,
    this.signalStrength,
    this.operatorName,
    this.isoCountryCode,
    this.mobileNetworkCode,
    this.mobileCountryCode,
    required this.timestamp,
  });

  factory MobileDataInfo.initial() => MobileDataInfo(
        isConnected: false,
        dataType: MobileDataType.none,
        timestamp: DateTime.now(),
      );

  /// Signal quality as a percentage (0-100)
  /// Typical dBm ranges: -50 (excellent) to -120 (poor)
  String get signalQuality {
    if (signalStrength == null) return 'Unknown';
    final strength = signalStrength!;
    if (strength >= -50) return '🟢 Excellent';
    if (strength >= -70) return '🟢 Very Good';
    if (strength >= -85) return '🟡 Good';
    if (strength >= -100) return '🟠 Fair';
    return '🔴 Poor';
  }

  /// Get signal strength as percentage (0-100)
  double get signalPercentage {
    if (signalStrength == null) return 0;
    // dBm range: -50 (best) to -120 (worst)
    // Convert to 0-100 scale
    final strength = signalStrength!;
    if (strength >= -50) return 100;
    if (strength <= -120) return 0;
    // Linear interpolation between -50 and -120
    return ((strength + 120) / 70) * 100;
  }

  String get dataTypeDisplay {
    switch (dataType) {
      case MobileDataType.cellular2g:
        return '2G (EDGE/GPRS)';
      case MobileDataType.cellular3g:
        return '3G (UMTS/HSPA)';
      case MobileDataType.cellular4g:
        return '4G (LTE)';
      case MobileDataType.cellular5g:
        return '5G';
      case MobileDataType.none:
        return 'No Mobile Data';
      case MobileDataType.unknown:
        return 'Unknown';
    }
  }

  MobileDataInfo copyWith({
    bool? isConnected,
    MobileDataType? dataType,
    int? signalStrength,
    String? operatorName,
    String? isoCountryCode,
    String? mobileNetworkCode,
    String? mobileCountryCode,
    DateTime? timestamp,
  }) =>
      MobileDataInfo(
        isConnected: isConnected ?? this.isConnected,
        dataType: dataType ?? this.dataType,
        signalStrength: signalStrength ?? this.signalStrength,
        operatorName: operatorName ?? this.operatorName,
        isoCountryCode: isoCountryCode ?? this.isoCountryCode,
        mobileNetworkCode: mobileNetworkCode ?? this.mobileNetworkCode,
        mobileCountryCode: mobileCountryCode ?? this.mobileCountryCode,
        timestamp: timestamp ?? this.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'isConnected': isConnected,
        'dataType': dataType.name,
        'dataTypeDisplay': dataTypeDisplay,
        'signalStrength': signalStrength,
        'signalQuality': signalQuality,
        'signalPercentage': signalPercentage,
        'operatorName': operatorName,
        'isoCountryCode': isoCountryCode,
        'mobileNetworkCode': mobileNetworkCode,
        'mobileCountryCode': mobileCountryCode,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  String toString() =>
      'MobileDataInfo(connected=$isConnected, type=$dataTypeDisplay, strength=$signalStrength, operator=$operatorName)';
}
