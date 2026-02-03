// lib/src/core/errors/error_handler_impl.dart

import 'app_exception.dart';
import 'app_error_response.dart';
import 'error_handler.dart';
import 'exception_mapper.dart';
import '../../logging/logger.dart';

class ErrorHandlerImpl implements ErrorHandler {
  final Logger? _logger;

  ErrorHandlerImpl({Logger? logger}) : _logger = logger;

  @override
  void handleError(dynamic error, {StackTrace? stackTrace}) {
    final appException = parseError(error, stackTrace: stackTrace);
    logError(appException);
  }

  @override
  AppException parseError(dynamic error, {StackTrace? stackTrace}) {
    return ExceptionMapper.mapException(error, stackTrace);
  }

  @override
  AppErrorResponse createErrorResponse(AppException exception) {
    return AppErrorResponse.fromException(exception);
  }

  @override
  void logError(AppException exception) {
    try {
      _logger?.error(
        () => 'App error occurred: ${exception.message}',
        exception.originalException,
        exception.stackTrace,
      );
    } catch (e) {
    }
  }
}

