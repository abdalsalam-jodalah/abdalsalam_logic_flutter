// lib/src/app_state/models/memory_info.dart
enum MemoryPressureLevel { normal, warning, critical, unknown }

class MemoryInfo {
  final MemoryPressureLevel pressureLevel;
  final int? totalMemory;
  final int? freeMemory;
  final int? usedMemory;
  final double? memoryUsagePercentage;
  final int? availableMemory;
  final int? activeMemory;
  final int? inactiveMemory;
  final int? wiredMemory;
  final DateTime timestamp;

  const MemoryInfo({
    required this.pressureLevel,
    this.totalMemory,
    this.freeMemory,
    this.usedMemory,
    this.memoryUsagePercentage,
    this.availableMemory,
    this.activeMemory,
    this.inactiveMemory,
    this.wiredMemory,
    required this.timestamp,
  });

  bool get isNormal => pressureLevel == MemoryPressureLevel.normal;
  bool get isWarning => pressureLevel == MemoryPressureLevel.warning;
  bool get isCritical => pressureLevel == MemoryPressureLevel.critical;
  bool get shouldReduceMemoryUsage => isWarning || isCritical;

  String get totalMemoryGB =>
      totalMemory != null ? '${(totalMemory! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB' : 'N/A';
  String get freeMemoryMB =>
      freeMemory != null ? '${(freeMemory! / (1024 * 1024)).toStringAsFixed(0)} MB' : 'N/A';
  String get usedMemoryMB =>
      usedMemory != null ? '${(usedMemory! / (1024 * 1024)).toStringAsFixed(0)} MB' : 'N/A';
  String get availableMemoryMB =>
      availableMemory != null ? '${(availableMemory! / (1024 * 1024)).toStringAsFixed(0)} MB' : 'N/A';

  String get memoryStatus {
    if (memoryUsagePercentage == null) return 'Unknown';
    final usage = memoryUsagePercentage!;
    if (usage < 60) return '🟢 Healthy';
    if (usage < 80) return '🟡 Moderate';
    if (usage < 90) return '🟠 High';
    return '🔴 Critical';
  }

  MemoryInfo copyWith({
    MemoryPressureLevel? pressureLevel,
    int? totalMemory,
    int? freeMemory,
    int? usedMemory,
    double? memoryUsagePercentage,
    int? availableMemory,
    int? activeMemory,
    int? inactiveMemory,
    int? wiredMemory,
    DateTime? timestamp,
  }) {
    return MemoryInfo(
      pressureLevel: pressureLevel ?? this.pressureLevel,
      totalMemory: totalMemory ?? this.totalMemory,
      freeMemory: freeMemory ?? this.freeMemory,
      usedMemory: usedMemory ?? this.usedMemory,
      memoryUsagePercentage: memoryUsagePercentage ?? this.memoryUsagePercentage,
      availableMemory: availableMemory ?? this.availableMemory,
      activeMemory: activeMemory ?? this.activeMemory,
      inactiveMemory: inactiveMemory ?? this.inactiveMemory,
      wiredMemory: wiredMemory ?? this.wiredMemory,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pressureLevel': pressureLevel.name,
      'totalMemory': totalMemory,
      'freeMemory': freeMemory,
      'usedMemory': usedMemory,
      'memoryUsagePercentage': memoryUsagePercentage,
      'availableMemory': availableMemory,
      'activeMemory': activeMemory,
      'inactiveMemory': inactiveMemory,
      'wiredMemory': wiredMemory,
      'isNormal': isNormal,
      'isWarning': isWarning,
      'isCritical': isCritical,
      'shouldReduceMemoryUsage': shouldReduceMemoryUsage,
      'memoryStatus': memoryStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
