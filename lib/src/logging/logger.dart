// lib/src/logging/logger.dart
// Main logger interface for module-scoped logging

import 'log_level.dart';
import 'log_module.dart';

abstract class Logger {
  void trace(String Function() messageBuilder, [Object? error, StackTrace? stackTrace]);
  void debug(String Function() messageBuilder, [Object? error, StackTrace? stackTrace]);
  void info(String Function() messageBuilder, [Object? error, StackTrace? stackTrace]);
  void warning(String Function() messageBuilder, [Object? error, StackTrace? stackTrace]);
  void error(String Function() messageBuilder, [Object? error, StackTrace? stackTrace]);
  void fatal(String Function() messageBuilder, [Object? error, StackTrace? stackTrace]);

  void log(LogLevel level, String Function() messageBuilder,
      [Object? error, StackTrace? stackTrace]);

  LogModule get module;
}
