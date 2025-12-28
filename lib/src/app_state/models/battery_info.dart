// lib/src/app_state/models/battery_info.dart
enum BatteryState { charging, discharging, full, unknown }

enum PowerMode { normal, lowPower, unknown }

class BatteryInfo {
  final int? batteryLevel;
  final BatteryState batteryState;
  final PowerMode powerMode;
  final DateTime timestamp;

  const BatteryInfo({
    this.batteryLevel,
    required this.batteryState,
    required this.powerMode,
    required this.timestamp,
  });

  bool get isCharging => batteryState == BatteryState.charging;
  bool get isLowBattery => batteryLevel != null && batteryLevel! < 20;
  bool get isCriticalBattery => batteryLevel != null && batteryLevel! < 10;
  bool get isLowPowerMode => powerMode == PowerMode.lowPower;

  BatteryInfo copyWith({
    int? batteryLevel,
    BatteryState? batteryState,
    PowerMode? powerMode,
    DateTime? timestamp,
  }) {
    return BatteryInfo(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryState: batteryState ?? this.batteryState,
      powerMode: powerMode ?? this.powerMode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batteryLevel': batteryLevel,
      'batteryState': batteryState.name,
      'powerMode': powerMode.name,
      'isCharging': isCharging,
      'isLowBattery': isLowBattery,
      'isCriticalBattery': isCriticalBattery,
      'isLowPowerMode': isLowPowerMode,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
