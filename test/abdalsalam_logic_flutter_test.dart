// test/abdalsalam_logic_flutter_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void main() {
  group('LoggerService', () {
    test('should create LoggerServiceImpl instance', () {
      final logger = LoggerServiceImpl();
      expect(logger, isA<LoggerService>());
    });

    test('should log messages without throwing', () {
      final logger = LoggerServiceImpl();
      expect(() => logger.debug('Test debug'), returnsNormally);
      expect(() => logger.info('Test info'), returnsNormally);
      expect(() => logger.warning('Test warning'), returnsNormally);
      expect(() => logger.error('Test error'), returnsNormally);
    });
  });

  group('AppException', () {
    test('should create NetworkException', () {
      final exception = NetworkException('Network error');
      expect(exception.message, 'Network error');
      expect(exception.toString(), 'Network error');
    });

    test('should create AuthException', () {
      final exception = AuthException('Auth error', code: 'AUTH_FAILED');
      expect(exception.message, 'Auth error');
      expect(exception.code, 'AUTH_FAILED');
    });
  });

  group('ErrorHandler', () {
    test('should create ErrorHandlerImpl', () {
      final logger = LoggerServiceImpl();
      final errorHandler = ErrorHandlerImpl(logger);
      expect(errorHandler, isA<ErrorHandler>());
    });

    test('should parse AppException correctly', () {
      final logger = LoggerServiceImpl();
      final errorHandler = ErrorHandlerImpl(logger);
      final exception = NetworkException('Test error');
      final parsed = errorHandler.parseError(exception);
      expect(parsed, isA<NetworkException>());
      expect(parsed.message, 'Test error');
    });
  });
}
