// lib/src/logging/log_filter.dart
// Filtering logic for log messages based on level, module, and configuration

import 'log_config.dart';
import 'log_environment.dart';
import 'log_level.dart';
import 'log_module.dart';

class LogFilter {
  final LogConfig config;
  final EnvironmentLogConfig envConfig;

  const LogFilter(this.config, this.envConfig);

  bool shouldLog({
    required LogLevel level,
    required LogModule module,
  }) {
    if (!module.enabled) {
      return false;
    }

    if (envConfig.disabledLevels?.contains(level) ?? false) {
      return false;
    }

    if (envConfig.disabledModuleTypes?.contains(module.moduleType) ?? false) {
      return false;
    }

    final moduleConfig = config.modules[module.moduleName];

    if (moduleConfig != null) {
      if (!moduleConfig.enabled) {
        return false;
      }

      final effectiveLevel = moduleConfig.level ?? envConfig.globalLevel;
      return level >= effectiveLevel;
    }

    if (!envConfig.allowUnregisteredModules) {
      return false;
    }

    final effectiveLevel = module.defaultLevel ?? envConfig.globalLevel;
    return level >= effectiveLevel;
  }

  bool shouldEnableColors() {
    return envConfig.enableColors;
  }
}
