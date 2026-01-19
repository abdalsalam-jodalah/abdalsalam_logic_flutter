// lib/src/core/errors/error_handler_impl.dart
import 'app_exception.dart';
import 'error_handler.dart';

class ErrorHandlerImpl implements ErrorHandler {
  ErrorHandlerImpl();

  @override
  void handleError(dynamic error, {StackTrace? stackTrace}) {
    // Parse error and handle - consumers can implement custom logging
    parseError(error);
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

