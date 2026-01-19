// lib/src/logging/log_config.dart
// Unified configuration for the logging system (backwards compatible + new split architecture)

import 'package:flutter/foundation.dart';
import 'log_level.dart';
import 'log_environment.dart';
import 'logger_core_config.dart';
import 'logger_module_registry_config.dart';

@immutable
class LogConfig {
  final LoggerCoreConfig coreConfig;
  final LoggerModuleRegistryConfig moduleConfig;

  const LogConfig({required this.coreConfig, required this.moduleConfig});

  factory LogConfig.split({
    required LoggerCoreConfig coreConfig,
    required LoggerModuleRegistryConfig moduleConfig,
  }) {
    return LogConfig(coreConfig: coreConfig, moduleConfig: moduleConfig);
  }

  factory LogConfig.simple({
    LogLevel? globalLevel,
    bool enableColors = true,
    Map<String, LogModuleConfig>? modules,
    bool allowUnregisteredModules = true,
    bool strictMode = false,
  }) {
    return LogConfig(
      coreConfig: LoggerCoreConfig.simple(
        globalLevel: globalLevel,
        allowUnregisteredModules: allowUnregisteredModules,
        strictMode: strictMode,
      ),
      moduleConfig: LoggerModuleRegistryConfig(
        globalLevel: globalLevel ?? LogLevel.info,
        enableColors: enableColors,
        modules: modules ?? {},
      ),
    );
  }

  factory LogConfig.recommended() {
    return LogConfig(
      coreConfig: LoggerCoreConfig.recommended(),
      moduleConfig: LoggerModuleRegistryConfig.minimal(),
    );
  }

  @Deprecated('Use LogConfig.simple() or LogConfig.split() instead')
  factory LogConfig.legacy({
    required EnvironmentLogConfig developmentConfig,
    EnvironmentLogConfig? profileConfig,
    EnvironmentLogConfig? releaseConfig,
    Map<String, LogModuleConfig>? modules,
  }) {
    final currentEnv = LoggerCoreConfig.detectEnvironment();
    final envConfig = _selectLegacyConfig(
      currentEnv,
      developmentConfig,
      profileConfig,
      releaseConfig,
    );

    return LogConfig(
      coreConfig: LoggerCoreConfig.simple(
        environment: currentEnv,
        globalLevel: envConfig.globalLevel,
        allowUnregisteredModules: envConfig.allowUnregisteredModules,
      ),
      moduleConfig: LoggerModuleRegistryConfig(
        globalLevel: envConfig.globalLevel,
        enableColors: envConfig.enableColors,
        modules: modules ?? {},
        disabledModuleTypes: envConfig.disabledModuleTypes,
        disabledLevels: envConfig.disabledLevels,
      ),
    );
  }

  static EnvironmentLogConfig _selectLegacyConfig(
    LogEnvironment env,
    EnvironmentLogConfig dev,
    EnvironmentLogConfig? profile,
    EnvironmentLogConfig? release,
  ) {
    switch (env) {
      case LogEnvironment.development:
        return dev;
      case LogEnvironment.profile:
        return profile ?? dev;
      case LogEnvironment.release:
        return release ?? dev;
    }
  }

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
