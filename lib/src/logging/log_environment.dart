// lib/src/logging/log_environment.dart
// Environment-specific logging configuration

import 'package:flutter/foundation.dart';
import 'log_level.dart';
import 'log_output.dart';

enum LogEnvironment { development, profile, release }

@Deprecated('Use LoggerCoreConfig and LoggerModuleRegistryConfig instead')
@immutable
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
}
