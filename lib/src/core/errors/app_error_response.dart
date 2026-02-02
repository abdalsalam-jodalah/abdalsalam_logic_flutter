// lib/src/core/errors/app_error_response.dart

import 'app_exception.dart';

class AppErrorResponse {
  final String safeMessage;
  final String errorCode;
  final bool isRecoverable;
  final AppExceptionSeverity severity;
  final AppExceptionSource source;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AppErrorResponse({
    required this.safeMessage,
    required this.errorCode,
    required this.isRecoverable,
    required this.severity,
    required this.source,
    required this.timestamp,
    this.metadata,
  });

  factory AppErrorResponse.fromException(AppException exception) {
    return AppErrorResponse(
      safeMessage: exception.message,
      errorCode: exception.code,
      isRecoverable: exception.isRecoverable,
      severity: exception.severity,
      source: exception.source,
      timestamp: DateTime.now(),
      metadata: exception.toMap(),
    );
  }

  AppErrorResponse copyWith({
    String? safeMessage,
    String? errorCode,
    bool? isRecoverable,
    AppExceptionSeverity? severity,
    AppExceptionSource? source,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AppErrorResponse(
      safeMessage: safeMessage ?? this.safeMessage,
      errorCode: errorCode ?? this.errorCode,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      severity: severity ?? this.severity,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'safeMessage': safeMessage,
      'errorCode': errorCode,
      'isRecoverable': isRecoverable,
      'severity': severity.name,
      'source': source.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() => 'AppErrorResponse: $safeMessage (code: $errorCode)';
}