// lib/src/logging/logger_module_registry_config.dart
// Module registration configuration for controlling what can log

import 'package:flutter/foundation.dart';
import 'log_level.dart';

@immutable
class LoggerModuleRegistryConfig {
  final LogLevel globalLevel;
  final bool enableColors;
  final Map<String, LogModuleConfig> modules;
  final Set<ModuleType>? disabledModuleTypes;
  final Set<LogLevel>? disabledLevels;

  const LoggerModuleRegistryConfig({
    required this.globalLevel,
    this.enableColors = true,
    this.modules = const {},
    this.disabledModuleTypes,
    this.disabledLevels,
  });

  factory LoggerModuleRegistryConfig.minimal({
    LogLevel? globalLevel,
    bool enableColors = true,
  }) {
    return LoggerModuleRegistryConfig(
      globalLevel: globalLevel ?? LogLevel.info,
      enableColors: enableColors,
    );
  }

  factory LoggerModuleRegistryConfig.withModules({
    required LogLevel globalLevel,
    required Map<String, LogModuleConfig> modules,
    bool enableColors = true,
    Set<ModuleType>? disabledModuleTypes,
    Set<LogLevel>? disabledLevels,
  }) {
    return LoggerModuleRegistryConfig(
      globalLevel: globalLevel,
      enableColors: enableColors,
      modules: modules,
      disabledModuleTypes: disabledModuleTypes,
      disabledLevels: disabledLevels,
    );
  }

  bool isModuleTypeEnabled(ModuleType type) {
    return disabledModuleTypes?.contains(type) != true;
  }

  bool isLevelEnabled(LogLevel level) {
    return disabledLevels?.contains(level) != true;
  }

  LogModuleConfig? getModuleConfig(String moduleName) {
    return modules[moduleName];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoggerModuleRegistryConfig &&
        other.globalLevel == globalLevel &&
        other.enableColors == enableColors &&
        _mapEquals(other.modules, modules) &&
        _setEquals(other.disabledModuleTypes, disabledModuleTypes) &&
        _setEquals(other.disabledLevels, disabledLevels);
  }

  @override
  int get hashCode =>
      globalLevel.hashCode ^
      enableColors.hashCode ^
      modules.hashCode ^
      disabledModuleTypes.hashCode ^
      disabledLevels.hashCode;

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    return a.every((e) => b.contains(e));
  }
}

@immutable
class LogModuleConfig {
  final ModuleType type;
  final bool enabled;
  final LogLevel? level;

  const LogModuleConfig({required this.type, this.enabled = true, this.level});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogModuleConfig &&
        other.type == type &&
        other.enabled == enabled &&
        other.level == level;
  }

  @override
  int get hashCode => type.hashCode ^ enabled.hashCode ^ level.hashCode;
}
