// lib/src/core/errors/error_handler.dart
import 'app_exception.dart';

abstract class ErrorHandler {
  void handleError(dynamic error, {StackTrace? stackTrace});
  AppException parseError(dynamic error);
  String getErrorMessage(dynamic error);
}

