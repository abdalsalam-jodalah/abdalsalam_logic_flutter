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
    required this.allowUnregisteredModules,
    required this.strictMode,
  });

  LogLevel getLevelForEnvironment(LogEnvironment env) {
    final level = environmentLevels[env];
    if (level == null) {
      throw StateError(
        'No log level configured for environment: ${env.name}. '
        'You must explicitly configure log levels for all environments.',
      );
    }
    return level;
  }

  LogLevel getLevelForCurrentEnvironment() {
    return getLevelForEnvironment(environment);
  }

  Set<LogTarget> getTargetsForEnvironment(LogEnvironment env) {
    final targets = targetsPerEnvironment[env];
    if (targets == null || targets.isEmpty) {
      throw StateError(
        'No log targets configured for environment: ${env.name}. '
        'You must explicitly configure targets for all environments.',
      );
    }
    return targets;
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
