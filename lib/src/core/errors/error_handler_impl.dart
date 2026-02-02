// lib/src/core/errors/error_handler_impl.dart

import 'app_exception.dart';
import 'app_error_response.dart';
import 'error_handler.dart';
import 'exception_mapper.dart';

class ErrorHandlerImpl implements ErrorHandler {
  ErrorHandlerImpl();

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
    // TODO: Integrate with logging service when available
    // For now, consumers can override this method for custom logging
  }
}

