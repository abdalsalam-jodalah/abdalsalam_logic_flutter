// lib/src/core/errors/error_handler_impl.dart
import 'app_exception.dart';
import 'error_handler.dart';
import '../../logging/logger_service.dart';

class ErrorHandlerImpl implements ErrorHandler {
  final LoggerService _logger;

  ErrorHandlerImpl(this._logger);

  @override
  void handleError(dynamic error, {StackTrace? stackTrace}) {
    final appException = parseError(error);
    _logger.error(
      'Error occurred: ${appException.message}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  AppException parseError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is Exception) {
      return BaseAppException(
        error.toString(),
        originalError: error,
      );
    }

    return BaseAppException(
      'An unexpected error occurred',
      originalError: error,
    );
  }

  @override
  String getErrorMessage(dynamic error) {
    return parseError(error).message;
  }
}

