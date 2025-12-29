// lib/src/app_state/models/battery_info.dart
enum BatteryState { charging, discharging, full, unknown }

enum PowerMode { normal, lowPower, unknown }

enum BatteryHealth { good, overheat, dead, overVoltage, cold, unknown }

enum ChargingSource { ac, usb, wireless, unknown }

class BatteryInfo {
  final int? batteryLevel;
  final BatteryState batteryState;
  final PowerMode powerMode;
  final BatteryHealth? health;
  final int? temperature;
  final int? voltage;
  final String? technology;
  final ChargingSource? chargingSource;
  final int? capacity;
  final int? chargeCounter;
  final int? currentAverage;
  final int? currentNow;
  final int? energyCounter;
  final DateTime timestamp;

  const BatteryInfo({
    this.batteryLevel,
    required this.batteryState,
    required this.powerMode,
    this.health,
    this.temperature,
    this.voltage,
    this.technology,
    this.chargingSource,
    this.capacity,
    this.chargeCounter,
    this.currentAverage,
    this.currentNow,
    this.energyCounter,
    required this.timestamp,
  });

  bool get isCharging => batteryState == BatteryState.charging;
  bool get isLowBattery => batteryLevel != null && batteryLevel! < 20;
  bool get isCriticalBattery => batteryLevel != null && batteryLevel! < 10;
  bool get isLowPowerMode => powerMode == PowerMode.lowPower;
  bool get isHealthy => health == BatteryHealth.good || health == null;
  bool get isOverheating => temperature != null && temperature! > 450;
  
  double? get temperatureCelsius => temperature != null ? temperature! / 10.0 : null;
  double? get voltageVolts => voltage != null ? voltage! / 1000.0 : null;
  
  String get healthStatus {
    if (health == null) return 'Unknown';
    switch (health!) {
      case BatteryHealth.good:
        return 'Good ✅';
      case BatteryHealth.overheat:
        return 'Overheating ⚠️';
      case BatteryHealth.dead:
        return 'Dead ❌';
      case BatteryHealth.overVoltage:
        return 'Over Voltage ⚠️';
      case BatteryHealth.cold:
        return 'Cold ❄️';
      case BatteryHealth.unknown:
        return 'Unknown';
    }
  }

  BatteryInfo copyWith({
    int? batteryLevel,
    BatteryState? batteryState,
    PowerMode? powerMode,
    BatteryHealth? health,
    int? temperature,
    int? voltage,
    String? technology,
    ChargingSource? chargingSource,
    int? capacity,
    int? chargeCounter,
    int? currentAverage,
    int? currentNow,
    int? energyCounter,
    DateTime? timestamp,
  }) {
    return BatteryInfo(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryState: batteryState ?? this.batteryState,
      powerMode: powerMode ?? this.powerMode,
      health: health ?? this.health,
      temperature: temperature ?? this.temperature,
      voltage: voltage ?? this.voltage,
      technology: technology ?? this.technology,
      chargingSource: chargingSource ?? this.chargingSource,
      capacity: capacity ?? this.capacity,
      chargeCounter: chargeCounter ?? this.chargeCounter,
      currentAverage: currentAverage ?? this.currentAverage,
      currentNow: currentNow ?? this.currentNow,
      energyCounter: energyCounter ?? this.energyCounter,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batteryLevel': batteryLevel,
      'batteryState': batteryState.name,
      'powerMode': powerMode.name,
      'health': health?.name,
      'healthStatus': healthStatus,
      'temperature': temperature,
      'temperatureCelsius': temperatureCelsius,
      'voltage': voltage,
      'voltageVolts': voltageVolts,
      'technology': technology,
      'chargingSource': chargingSource?.name,
      'capacity': capacity,
      'chargeCounter': chargeCounter,
      'currentAverage': currentAverage,
      'currentNow': currentNow,
      'energyCounter': energyCounter,
      'isCharging': isCharging,
      'isLowBattery': isLowBattery,
      'isCriticalBattery': isCriticalBattery,
      'isLowPowerMode': isLowPowerMode,
      'isHealthy': isHealthy,
      'isOverheating': isOverheating,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}