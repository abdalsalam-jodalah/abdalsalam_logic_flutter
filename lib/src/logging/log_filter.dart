// lib/src/logging/log_filter.dart
// Filtering logic for log messages based on level, module, and configuration

import 'package:flutter/foundation.dart';
import 'log_config.dart';
import 'log_level.dart';
import 'log_module.dart';

class LogFilter {
  final LogConfig config;

  const LogFilter(this.config);

  bool shouldLog({
    required LogLevel level,
    required LogModule module,
  }) {
    if (!module.enabled) {
      return false;
    }

    if (config.disabledModuleTypes?.contains(module.moduleType) ?? false) {
      return false;
    }

    final moduleConfig = config.modules[module.moduleName];

    if (moduleConfig != null) {
      if (!moduleConfig.enabled) {
        return false;
      }

      final effectiveLevel = moduleConfig.level ?? config.globalLevel;
      return level >= effectiveLevel;
    }

    if (config.rejectUnregisteredModules) {
      return false;
    }

    final effectiveLevel = module.defaultLevel ?? config.globalLevel;
    return level >= effectiveLevel;
  }

  bool shouldEnableColors() {
    if (kReleaseMode) {
      return false;
    }
    return config.enableColors;
  }

  bool shouldOutputToConsole() {
    if (kReleaseMode) {
      return config.enableConsoleInRelease;
    }
    return true;
  }
}
