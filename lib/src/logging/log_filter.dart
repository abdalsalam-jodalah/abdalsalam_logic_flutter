// lib/src/logging/log_filter.dart
// Filtering logic for log messages based on level, module, and configuration

import 'logger_core_config.dart';
import 'logger_module_registry_config.dart';
import 'log_level.dart';
import 'log_module.dart';

class LogFilter {
  final LoggerCoreConfig coreConfig;
  final LoggerModuleRegistryConfig moduleConfig;

  const LogFilter(this.coreConfig, this.moduleConfig);

  bool shouldLog({required LogLevel level, required LogModule module}) {
    if (!module.enabled) {
      return false;
    }

    if (!moduleConfig.isLevelEnabled(level)) {
      return false;
    }

    if (!moduleConfig.isModuleTypeEnabled(module.moduleType)) {
      return false;
    }

    final registeredModuleConfig = moduleConfig.getModuleConfig(
      module.moduleName,
    );

    if (registeredModuleConfig != null) {
      if (!registeredModuleConfig.enabled) {
        return false;
      }

      final effectiveLevel =
          registeredModuleConfig.level ??
          coreConfig.getLevelForCurrentEnvironment();
      return level >= effectiveLevel;
    }

    if (!coreConfig.allowUnregisteredModules) {
      return false;
    }

    final effectiveLevel =
        module.defaultLevel ?? coreConfig.getLevelForCurrentEnvironment();
    return level >= effectiveLevel;
  }

  bool shouldEnableColors() {
    return moduleConfig.enableColors;
  }
}
