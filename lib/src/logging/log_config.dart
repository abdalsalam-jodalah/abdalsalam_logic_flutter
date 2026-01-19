// lib/src/logging/log_config.dart
// Configuration classes for the logging system

import 'log_level.dart';

class LogModuleConfig {
  final ModuleType type;
  final bool enabled;
  final LogLevel? level;

  const LogModuleConfig({
    required this.type,
    this.enabled = true,
    this.level,
  });

  LogModuleConfig copyWith({
    ModuleType? type,
    bool? enabled,
    LogLevel? level,
  }) {
    return LogModuleConfig(
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      level: level ?? this.level,
    );
  }
}

class LogConfig {
  final LogLevel globalLevel;
  final bool enableColors;
  final Map<String, LogModuleConfig> modules;
  final bool rejectUnregisteredModules;
  final bool enableConsoleInRelease;
  final Set<ModuleType>? disabledModuleTypes;

  const LogConfig({
    required this.globalLevel,
    this.enableColors = true,
    this.modules = const {},
    this.rejectUnregisteredModules = false,
    this.enableConsoleInRelease = false,
    this.disabledModuleTypes,
  });

  LogConfig copyWith({
    LogLevel? globalLevel,
    bool? enableColors,
    Map<String, LogModuleConfig>? modules,
    bool? rejectUnregisteredModules,
    bool? enableConsoleInRelease,
    Set<ModuleType>? disabledModuleTypes,
  }) {
    return LogConfig(
      globalLevel: globalLevel ?? this.globalLevel,
      enableColors: enableColors ?? this.enableColors,
      modules: modules ?? this.modules,
      rejectUnregisteredModules:
          rejectUnregisteredModules ?? this.rejectUnregisteredModules,
      enableConsoleInRelease:
          enableConsoleInRelease ?? this.enableConsoleInRelease,
      disabledModuleTypes: disabledModuleTypes ?? this.disabledModuleTypes,
    );
  }
}
