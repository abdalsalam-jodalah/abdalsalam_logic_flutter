// lib/src/logging/log_module.dart
// Module registration system for scoped logging

import 'log_level.dart';

class LogModule {
  final String moduleName;
  final ModuleType moduleType;
  final LogLevel? defaultLevel;
  final bool enabled;

  const LogModule({
    required this.moduleName,
    required this.moduleType,
    this.defaultLevel,
    this.enabled = true,
  });

  LogModule copyWith({
    String? moduleName,
    ModuleType? moduleType,
    LogLevel? defaultLevel,
    bool? enabled,
  }) {
    return LogModule(
      moduleName: moduleName ?? this.moduleName,
      moduleType: moduleType ?? this.moduleType,
      defaultLevel: defaultLevel ?? this.defaultLevel,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogModule && other.moduleName == moduleName;
  }

  @override
  int get hashCode => moduleName.hashCode;

  @override
  String toString() =>
      'LogModule(name: $moduleName, type: $moduleType, level: $defaultLevel, enabled: $enabled)';
}
