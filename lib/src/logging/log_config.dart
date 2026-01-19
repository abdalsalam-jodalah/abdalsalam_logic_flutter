// lib/src/logging/log_config.dart
// Configuration classes for the logging system

import 'package:flutter/foundation.dart';
import 'log_level.dart';
import 'log_environment.dart';

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
  final Map<String, LogModuleConfig> modules;
  final EnvironmentLogConfig developmentConfig;
  final EnvironmentLogConfig? profileConfig;
  final EnvironmentLogConfig? releaseConfig;

  const LogConfig({
    required this.developmentConfig,
    this.profileConfig,
    this.releaseConfig,
    this.modules = const {},
  });

  EnvironmentLogConfig getConfigForCurrentEnvironment() {
    if (kReleaseMode) {
      return releaseConfig ?? developmentConfig;
    } else if (kProfileMode) {
      return profileConfig ?? developmentConfig;
    }
    return developmentConfig;
  }

  EnvironmentLogConfig getConfigForEnvironment(LogEnvironment environment) {
    switch (environment) {
      case LogEnvironment.development:
        return developmentConfig;
      case LogEnvironment.profile:
        return profileConfig ?? developmentConfig;
      case LogEnvironment.release:
        return releaseConfig ?? developmentConfig;
    }
  }

  LogConfig copyWith({
    Map<String, LogModuleConfig>? modules,
    EnvironmentLogConfig? developmentConfig,
    EnvironmentLogConfig? profileConfig,
    EnvironmentLogConfig? releaseConfig,
  }) {
    return LogConfig(
      modules: modules ?? this.modules,
      developmentConfig: developmentConfig ?? this.developmentConfig,
      profileConfig: profileConfig ?? this.profileConfig,
      releaseConfig: releaseConfig ?? this.releaseConfig,
    );
  }
}
