// lib/src/logging/log_module.dart
// Module registration system for scoped logging

import 'package:flutter/foundation.dart';
import 'log_level.dart';

@immutable
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
