// lib/src/app_state/models/memory_info.dart
enum MemoryPressureLevel { normal, warning, critical, unknown }

class MemoryInfo {
  final MemoryPressureLevel pressureLevel;
  final DateTime timestamp;

  const MemoryInfo({required this.pressureLevel, required this.timestamp});

  bool get isNormal => pressureLevel == MemoryPressureLevel.normal;
  bool get isWarning => pressureLevel == MemoryPressureLevel.warning;
  bool get isCritical => pressureLevel == MemoryPressureLevel.critical;
  bool get shouldReduceMemoryUsage => isWarning || isCritical;

  MemoryInfo copyWith({
    MemoryPressureLevel? pressureLevel,
    DateTime? timestamp,
  }) {
    return MemoryInfo(
      pressureLevel: pressureLevel ?? this.pressureLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pressureLevel': pressureLevel.name,
      'isNormal': isNormal,
      'isWarning': isWarning,
      'isCritical': isCritical,
      'shouldReduceMemoryUsage': shouldReduceMemoryUsage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
