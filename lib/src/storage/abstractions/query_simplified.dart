// lib/src/storage/abstractions/query_simplified.dart

import '../exceptions/storage_exceptions.dart';

/// Simplified query abstraction for filtering and sorting data.
///
/// **MINIMAL BACKEND-AGNOSTIC DSL**
/// Supports only essential query operations:
/// - Simple field-based filters (equals, comparison, contains)
/// - Single-field sorting
/// - Limit/offset pagination
///
/// Does NOT support:
/// - Complex joins or relationships (too SQL-specific)
/// - Aggregations (backend-dependent)
/// - Sub-queries (too complex for abstraction)
/// - Field projection (implementation detail)
///
/// Generic type [T] represents the entity type being queried.
///
/// Example:
/// ```dart
/// final query = storage.query()
///   .where('status', isEqualTo: 'active')
///   .where('age', isGreaterThan: 18)
///   .orderBy('createdAt', descending: true)
///   .limit(10);
///
/// final results = await query.execute();
/// ```
abstract class StorageQuery<T> {
  /// Adds a filter condition to the query.
  ///
  /// Multiple calls are combined with AND logic.
  ///
  /// Named parameters specify the comparison type:
  /// - [isEqualTo] - field == value
  /// - [isNotEqualTo] - field != value
  /// - [isGreaterThan] - field > value
  /// - [isGreaterThanOrEqualTo] - field >= value
  /// - [isLessThan] - field < value
  /// - [isLessThanOrEqualTo] - field <= value
  /// - [contains] - field contains value (for strings/lists)
  ///
  /// Only ONE comparison parameter should be provided per call.
  ///
  /// Throws:
  /// - [StorageOperationException] if multiple comparisons provided
  /// - [StorageUnsupportedException] if comparison not supported
  StorageQuery<T> where(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    String? contains,
  });

  /// Sorts results by the specified field.
  ///
  /// Only supports single-field sorting in this minimal abstraction.
  /// Multiple calls overwrite previous sorting.
  ///
  /// Parameters:
  /// - [field] - Field name to sort by
  /// - [descending] - Sort direction (default: false = ascending)
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if sorting not supported
  StorageQuery<T> orderBy(String field, {bool descending = false});

  /// Limits the number of results returned.
  ///
  /// Parameters:
  /// - [count] - Maximum number of results to return
  ///
  /// Throws:
  /// - [StorageOperationException] if limit is negative
  StorageQuery<T> limit(int count);

  /// Skips the specified number of results.
  ///
  /// Used for pagination in combination with [limit].
  ///
  /// Parameters:
  /// - [count] - Number of results to skip
  ///
  /// Throws:
  /// - [StorageOperationException] if offset is negative
  StorageQuery<T> offset(int count);

  /// Executes the query and returns results.
  ///
  /// Returns a list of entities matching all filter conditions.
  /// Results are sorted and paginated according to query configuration.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query execution fails
  Future<List<T>> execute();

  /// Executes the query and returns the count of matching results.
  ///
  /// More efficient than calling execute().length for large datasets.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query execution fails
  Future<int> count();
}
