// lib/src/storage/types/storage_result_minimal.dart

/// Sealed result type for storage operations.
///
/// **MINIMAL RESULT WRAPPER**
/// Provides functional error handling without unnecessary complexity.
///
/// Use this for operations that need explicit success/failure handling:
/// ```dart
/// final result = await storage.tryGet(key);
/// switch (result) {
///   case StorageSuccess(value: final data):
///     print('Got: $data');
///   case StorageFailure(error: final err):
///     print('Error: $err');
/// }
/// ```
///
/// Most operations should throw exceptions directly rather than wrapping in Result.
/// Use Result only when:
/// - Caller needs to handle both success and failure
/// - Multiple error types need differentiation
/// - Performance-critical code avoids exception overhead
sealed class StorageResult<T> {
  const StorageResult();
}

/// Successful storage operation result.
final class StorageSuccess<T> extends StorageResult<T> {
  /// The value returned by the operation.
  final T value;

  const StorageSuccess(this.value);

  @override
  String toString() => 'StorageSuccess($value)';
}

/// Failed storage operation result.
final class StorageFailure<T> extends StorageResult<T> {
  /// The exception that caused the failure.
  final Exception error;

  /// Optional error context or details.
  final String? message;

  const StorageFailure(this.error, [this.message]);

  @override
  String toString() => 'StorageFailure($error${message != null ? ': $message' : ''})';
}

/// Extension methods for working with StorageResult.
extension StorageResultExtensions<T> on StorageResult<T> {
  /// Returns the value if success, or null if failure.
  T? get valueOrNull {
    return switch (this) {
      StorageSuccess(value: final v) => v,
      StorageFailure() => null,
    };
  }

  /// Returns the value if success, or throws the error if failure.
  T get valueOrThrow {
    return switch (this) {
      StorageSuccess(value: final v) => v,
      StorageFailure(error: final e) => throw e,
    };
  }

  /// Returns the value if success, or the provided default if failure.
  T valueOr(T defaultValue) {
    return switch (this) {
      StorageSuccess(value: final v) => v,
      StorageFailure() => defaultValue,
    };
  }

  /// Returns true if this is a success result.
  bool get isSuccess => this is StorageSuccess<T>;

  /// Returns true if this is a failure result.
  bool get isFailure => this is StorageFailure<T>;

  /// Maps the success value to a new type.
  StorageResult<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      StorageSuccess(value: final v) => StorageSuccess(transform(v)),
      StorageFailure(error: final e, message: final m) => StorageFailure(e, m),
    };
  }
}
