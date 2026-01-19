// lib/src/logging/log_formatter.dart
// Formats log messages with structured output and color support

import 'package:intl/intl.dart';
import 'log_level.dart';
import 'log_module.dart';

abstract class LogFormatter {
  String format({
    required DateTime timestamp,
    required LogLevel level,
    required LogModule module,
    required String message,
    bool enableColors = true,
    Object? error,
    StackTrace? stackTrace,
  });
}

class DefaultLogFormatter implements LogFormatter {
  static const String _reset = '\x1B[0m';
  final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');

  @override
  String format({
    required DateTime timestamp,
    required LogLevel level,
    required LogModule module,
    required String message,
    bool enableColors = true,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timeStr = _timeFormat.format(timestamp);
    final levelStr = level.displayName.padRight(5);
    final moduleStr = module.moduleName;
    final typeStr = module.moduleType.displayName;

    final baseMessage = '[$timeStr] [$levelStr] [$moduleStr] [$typeStr] $message';

    final coloredMessage = enableColors
        ? '${level.ansiColor}$baseMessage$_reset'
        : baseMessage;

    final buffer = StringBuffer(coloredMessage);

    if (error != null) {
      buffer.write('\n${enableColors ? '\x1B[31m' : ''}Error: $error${enableColors ? _reset : ''}');
    }

    if (stackTrace != null) {
      buffer.write('\n${enableColors ? '\x1B[90m' : ''}$stackTrace${enableColors ? _reset : ''}');
    }

    return buffer.toString();
  }
}
