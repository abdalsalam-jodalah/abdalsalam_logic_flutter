// lib/src/logging/log_config.dart
// Unified configuration for the logging system (strict split architecture)

import 'package:flutter/foundation.dart';
import 'logger_core_config.dart';
import 'logger_module_registry_config.dart';

@immutable
class LogConfig {
  final LoggerCoreConfig coreConfig;
  final LoggerModuleRegistryConfig moduleConfig;

  const LogConfig({required this.coreConfig, required this.moduleConfig});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogConfig &&
        other.coreConfig == coreConfig &&
        other.moduleConfig == moduleConfig;
  }

  @override
  int get hashCode => coreConfig.hashCode ^ moduleConfig.hashCode;
}
