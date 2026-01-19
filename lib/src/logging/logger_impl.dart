// lib/src/logging/logger_impl.dart
// Singleton logger implementation with mandatory initialization contract

import 'package:flutter/foundation.dart';
import 'log_config.dart';
import 'log_filter.dart';
import 'log_formatter.dart';
import 'log_level.dart';
import 'log_module.dart';
import 'log_output.dart';
import 'logger.dart';

class LoggerImpl implements Logger {
  static LoggerImpl? _instance;
  static LogConfig? _config;
  static LogFilter? _filter;
  static LogFormatter? _formatter;
  static LogOutput? _output;
  static bool _initialized = false;

  final LogModule _module;

  LoggerImpl._(this._module);

  static void initialize(LogConfig config) {
    if (_initialized) {
      throw StateError(
        'Logger is already initialized. Re-initialization is not allowed.',
      );
    }

    _config = config;
    _filter = LogFilter(config);
    _formatter = DefaultLogFormatter();
    _output = ConsoleOutput(enableInRelease: config.enableConsoleInRelease);
    _initialized = true;
  }

  static Logger forModule(LogModule module) {
    if (!_initialized) {
      if (kDebugMode || kProfileMode) {
        throw StateError(
          'Logger must be initialized before use. Call Logger.initialize(config) first.',
        );
      }
      return _NoOpLogger(module);
    }

    return LoggerImpl._(module);
  }

  static void dispose() {
    _output?.close();
    _config = null;
    _filter = null;
    _formatter = null;
    _output = null;
    _initialized = false;
    _instance = null;
  }

  @override
  LogModule get module => _module;

  @override
  void trace(String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.trace, messageBuilder, error, stackTrace);
  }

  @override
  void debug(String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.debug, messageBuilder, error, stackTrace);
  }

  @override
  void info(String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.info, messageBuilder, error, stackTrace);
  }

  @override
  void warning(String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.warning, messageBuilder, error, stackTrace);
  }

  @override
  void error(String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.error, messageBuilder, error, stackTrace);
  }

  @override
  void fatal(String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    log(LogLevel.fatal, messageBuilder, error, stackTrace);
  }

  @override
  void log(LogLevel level, String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]) {
    if (_filter == null || _formatter == null || _output == null) {
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

    _output!.write(formattedMessage);
  }
}

class _NoOpLogger implements Logger {
  final LogModule _module;

  const _NoOpLogger(this._module);

  @override
  LogModule get module => _module;

  @override
  void trace(String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};

  @override
  void debug(String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};

  @override
  void info(String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};

  @override
  void warning(String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};

  @override
  void error(String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};

  @override
  void fatal(String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};

  @override
  void log(LogLevel level, String Function() messageBuilder,
          [Object? error, StackTrace? stackTrace]) =>
      {};
}
