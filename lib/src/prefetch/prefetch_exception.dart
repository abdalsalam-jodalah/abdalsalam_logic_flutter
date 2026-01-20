// lib/src/prefetch/prefetch_exception.dart
// Exception types for prefetch operations

class PrefetchException implements Exception {
  final String message;
  final String? requestId;
  final Object? originalError;
  final StackTrace? stackTrace;

  const PrefetchException({
    required this.message,
    this.requestId,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PrefetchException: $message');
    if (requestId != null) buffer.write(' (Request: $requestId)');
    if (originalError != null) buffer.write('\nCaused by: $originalError');
    return buffer.toString();
  }
}

class PrefetchNetworkException extends PrefetchException {
  const PrefetchNetworkException({
    required super.message,
    super.requestId,
    super.originalError,
    super.stackTrace,
  });
}

class PrefetchStorageException extends PrefetchException {
  const PrefetchStorageException({
    required super.message,
    super.requestId,
    super.originalError,
    super.stackTrace,
  });
}

class PrefetchCancelledException extends PrefetchException {
  const PrefetchCancelledException({
    required super.message,
    super.requestId,
  });
}

class PrefetchTimeoutException extends PrefetchException {
  final Duration timeout;

  const PrefetchTimeoutException({
    required super.message,
    required this.timeout,
    super.requestId,
  });

  @override
  String toString() {
    return 'PrefetchTimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
  }
}
