// lib/src/logging/logger_impl.dart
// Singleton logger implementation with mandatory initialization contract and strict mode support

import 'package:flutter/foundation.dart';
import 'log_config.dart';
import 'log_filter.dart';
import 'log_formatter.dart';
import 'log_level.dart';
import 'log_module.dart';
import 'log_output.dart';
import 'log_target.dart';
import 'logger_core_config.dart';
import 'logger_module_registry_config.dart';
import 'logger.dart';

class LoggerImpl implements Logger {
  static LoggerCoreConfig? _coreConfig;
  static LoggerModuleRegistryConfig? _moduleConfig;
  static LogFilter? _filter;
  static LogFormatter? _formatter;
  static final Map<LogTarget, LogOutput> _outputs = {};
  static bool _initialized = false;

  final LogModule _module;

  LoggerImpl._(this._module);

  static void initialize(LogConfig config) {
    if (_initialized) {
      final errorMessage =
          'Logger is already initialized. Re-initialization is not allowed.';
      if (config.coreConfig.strictMode) {
        throw StateError(errorMessage);
      } else {
        debugPrint('Warning: $errorMessage');
        return;
      }
    }

    _coreConfig = config.coreConfig;
    _moduleConfig = config.moduleConfig;
    _filter = LogFilter(config.coreConfig, config.moduleConfig);
    _formatter = DefaultLogFormatter();

    _initializeOutputs();
    _initialized = true;
  }

  static void _initializeOutputs() {
    _outputs.clear();
    final targets = _coreConfig!.getTargetsForCurrentEnvironment();

    for (final target in targets) {
      switch (target) {
        case LogTarget.console:
          _outputs[target] = ConsoleOutput(
            enableInRelease: _coreConfig!.environment.name == 'release',
          );
          break;
        case LogTarget.file:
          _outputs[target] = FileOutput();
          break;
        case LogTarget.memory:
          _outputs[target] = MemoryOutput();
          break;
        case LogTarget.remote:
          break;
      }
    }
  }

  static Logger forModule(LogModule module) {
    if (!_initialized) {
      final errorMessage =
          'Logger must be initialized before use. Call LoggerImpl.initialize(config) first.';

      if (kDebugMode || kProfileMode) {
        if (_coreConfig?.strictMode ?? false) {
          throw StateError(errorMessage);
        } else {
          throw StateError(errorMessage);
        }
      }

      return _NoOpLogger(module);
    }

    return LoggerImpl._(module);
  }

  static Future<void> dispose() async {
    for (final output in _outputs.values) {
      await output.close();
    }
    _outputs.clear();
    _coreConfig = null;
    _moduleConfig = null;
    _filter = null;
    _formatter = null;
    _initialized = false;
  }

  static MemoryOutput? getMemoryOutput() {
    return _outputs[LogTarget.memory] as MemoryOutput?;
  }

  static bool get isInitialized => _initialized;

  static LoggerCoreConfig? get coreConfig => _coreConfig;

  static LoggerModuleRegistryConfig? get moduleConfig => _moduleConfig;

  @override
  LogModule get module => _module;

  @override
  void trace(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log(LogLevel.trace, messageBuilder, error, stackTrace);
  }

  @override
  void debug(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log(LogLevel.debug, messageBuilder, error, stackTrace);
  }

  @override
  void info(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log(LogLevel.info, messageBuilder, error, stackTrace);
  }

  @override
  void warning(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log(LogLevel.warning, messageBuilder, error, stackTrace);
  }

  @override
  void error(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log(LogLevel.error, messageBuilder, error, stackTrace);
  }

  @override
  void fatal(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    log(LogLevel.fatal, messageBuilder, error, stackTrace);
  }

  @override
  void log(
    LogLevel level,
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (_filter == null || _formatter == null) {
      if (_coreConfig?.strictMode ?? false) {
        throw StateError('Logger components not properly initialized');
      }
      return;
    }

    if (!_filter!.shouldLog(level: level, module: _module)) {
      return;
    }

    final message = messageBuilder();

    final formattedMessage = _formatter!.format(
      timestamp: DateTime.now(),
      level: level,
      module: _module,
      message: message,
      enableColors: _filter!.shouldEnableColors(),
      error: error,
      stackTrace: stackTrace,
    );

    for (final output in _outputs.values) {
      try {
        output.write(formattedMessage);
      } catch (e) {
        if (_coreConfig?.strictMode ?? false) {
          rethrow;
        }
        debugPrint('Logger output failed: $e');
      }
    }
  }
}

class _NoOpLogger implements Logger {
  final LogModule _module;

  const _NoOpLogger(this._module);

  @override
  LogModule get module => _module;

  @override
  void trace(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};

  @override
  void debug(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};

  @override
  void info(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};

  @override
  void warning(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};

  @override
  void error(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};

  @override
  void fatal(
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};

  @override
  void log(
    LogLevel level,
    String Function() messageBuilder, [
    Object? error,
    StackTrace? stackTrace,
  ]) => {};
}
