// lib/src/logging/logger_service.dart
import 'package:logger/logger.dart';

abstract class LoggerService {
  void debug(String message, {dynamic error, StackTrace? stackTrace});
  void info(String message, {dynamic error, StackTrace? stackTrace});
  void warning(String message, {dynamic error, StackTrace? stackTrace});
  void error(String message, {dynamic error, StackTrace? stackTrace});
  void fatal(String message, {dynamic error, StackTrace? stackTrace});
}

class LoggerServiceImpl implements LoggerService {
  final Logger _logger;

  LoggerServiceImpl({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 2,
                errorMethodCount: 8,
                lineLength: 120,
                colors: true,
                printEmojis: true,
              ),
            );

  @override
  void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  @override
  void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

