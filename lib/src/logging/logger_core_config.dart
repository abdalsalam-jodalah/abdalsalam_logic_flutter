// lib/src/logging/logger_core_config.dart
// Core configuration defining how the logger system behaves

import 'package:flutter/foundation.dart';
import 'log_environment.dart';
import 'log_level.dart';
import 'log_target.dart';

@immutable
class LoggerCoreConfig {
  final LogEnvironment environment;
  final Map<LogEnvironment, LogLevel> environmentLevels;
  final Map<LogEnvironment, Set<LogTarget>> targetsPerEnvironment;
  final bool allowUnregisteredModules;
  final bool strictMode;

  const LoggerCoreConfig({
    required this.environment,
    required this.environmentLevels,
    required this.targetsPerEnvironment,
    this.allowUnregisteredModules = true,
    this.strictMode = false,
  });

  factory LoggerCoreConfig.simple({
    LogEnvironment? environment,
    LogLevel? globalLevel,
    Set<LogTarget>? targets,
    bool allowUnregisteredModules = true,
    bool strictMode = false,
  }) {
    final env = environment ?? _detectEnvironment();
    final level = globalLevel ?? LogLevel.info;
    final defaultTargets = targets ?? {LogTarget.console};

    return LoggerCoreConfig(
      environment: env,
      environmentLevels: {
        LogEnvironment.development: level,
        LogEnvironment.profile: level,
        LogEnvironment.release: level,
      },
      targetsPerEnvironment: {
        LogEnvironment.development: defaultTargets,
        LogEnvironment.profile: defaultTargets,
        LogEnvironment.release: defaultTargets,
      },
      allowUnregisteredModules: allowUnregisteredModules,
      strictMode: strictMode,
    );
  }

  factory LoggerCoreConfig.recommended() {
    final currentEnv = _detectEnvironment();

    return LoggerCoreConfig(
      environment: currentEnv,
      environmentLevels: {
        LogEnvironment.development: LogLevel.trace,
        LogEnvironment.profile: LogLevel.debug,
        LogEnvironment.release: LogLevel.error,
      },
      targetsPerEnvironment: {
        LogEnvironment.development: {LogTarget.console},
        LogEnvironment.profile: {LogTarget.console, LogTarget.file},
        LogEnvironment.release: {LogTarget.file, LogTarget.remote},
      },
      allowUnregisteredModules: true,
      strictMode: false,
    );
  }

  static LogEnvironment detectEnvironment() {
    if (kReleaseMode) return LogEnvironment.release;
    if (kProfileMode) return LogEnvironment.profile;
    return LogEnvironment.development;
  }

  static LogEnvironment _detectEnvironment() {
    return detectEnvironment();
  }

  LogLevel getLevelForEnvironment(LogEnvironment env) {
    return environmentLevels[env] ?? LogLevel.info;
  }

  LogLevel getLevelForCurrentEnvironment() {
    return getLevelForEnvironment(environment);
  }

  Set<LogTarget> getTargetsForEnvironment(LogEnvironment env) {
    return targetsPerEnvironment[env] ?? {LogTarget.console};
  }

  Set<LogTarget> getTargetsForCurrentEnvironment() {
    return getTargetsForEnvironment(environment);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoggerCoreConfig &&
        other.environment == environment &&
        _mapEquals(other.environmentLevels, environmentLevels) &&
        _mapSetEquals(other.targetsPerEnvironment, targetsPerEnvironment) &&
        other.allowUnregisteredModules == allowUnregisteredModules &&
        other.strictMode == strictMode;
  }

  @override
  int get hashCode =>
      environment.hashCode ^
      environmentLevels.hashCode ^
      targetsPerEnvironment.hashCode ^
      allowUnregisteredModules.hashCode ^
      strictMode.hashCode;

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  bool _mapSetEquals<K, V>(Map<K, Set<V>>? a, Map<K, Set<V>>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final setA = a[key]!;
      final setB = b[key]!;
      if (setA.length != setB.length) return false;
      if (!setA.every((e) => setB.contains(e))) return false;
    }
    return true;
  }
}
