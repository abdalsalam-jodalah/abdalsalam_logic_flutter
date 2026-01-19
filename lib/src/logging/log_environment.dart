// lib/src/logging/log_environment.dart
// Environment-specific logging configuration

import 'log_level.dart';
import 'log_output.dart';

enum LogEnvironment {
  development,
  profile,
  release;
}

class EnvironmentLogConfig {
  final LogLevel globalLevel;
  final bool enableColors;
  final List<LogOutput> outputs;
  final bool allowUnregisteredModules;
  final Set<ModuleType>? disabledModuleTypes;
  final Set<LogLevel>? disabledLevels;

  const EnvironmentLogConfig({
    required this.globalLevel,
    this.enableColors = true,
    this.outputs = const [],
    this.allowUnregisteredModules = true,
    this.disabledModuleTypes,
    this.disabledLevels,
  });

  EnvironmentLogConfig copyWith({
    LogLevel? globalLevel,
    bool? enableColors,
    List<LogOutput>? outputs,
    bool? allowUnregisteredModules,
    Set<ModuleType>? disabledModuleTypes,
    Set<LogLevel>? disabledLevels,
  }) {
    return EnvironmentLogConfig(
      globalLevel: globalLevel ?? this.globalLevel,
      enableColors: enableColors ?? this.enableColors,
      outputs: outputs ?? this.outputs,
      allowUnregisteredModules:
          allowUnregisteredModules ?? this.allowUnregisteredModules,
      disabledModuleTypes: disabledModuleTypes ?? this.disabledModuleTypes,
      disabledLevels: disabledLevels ?? this.disabledLevels,
    );
  }
}
