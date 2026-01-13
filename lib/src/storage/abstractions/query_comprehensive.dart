// lib/src/storage/abstractions/query_comprehensive.dart

import '../exceptions/storage_exceptions.dart';

/// Comprehensive query abstraction for filtering, sorting, and retrieving data.
///
/// **FULL-FEATURED QUERY DSL** supporting:
/// - Complex filters with multiple operators
/// - Multi-field sorting
/// - Pagination (offset/limit and cursor-based)
/// - Aggregations (count, sum, avg, min, max)
/// - Field projection (select specific fields)
/// - Grouping
/// - Joins (if supported)
///
/// Generic type [T] represents the entity type being queried.
///
/// Example:
/// ```dart
/// final query = storage.query()
///   .where('status', isEqualTo: 'active')
///   .where('age', isGreaterThan: 18)
///   .orderBy('createdAt', descending: true)
///   .orderBy('name')
///   .limit(10);
///
/// final results = await query.execute();
/// ```
abstract class EntityQuery<T> {
  // ============================================================================
  // FILTERING
  // ============================================================================

  /// Adds a filter condition to the query.
  ///
  /// Multiple calls are combined with AND logic.
  /// Use [or] to combine filters with OR logic.
  ///
  /// Comparison operators:
  /// - [isEqualTo] - field == value
  /// - [isNotEqualTo] - field != value
  /// - [isGreaterThan] - field > value
  /// - [isGreaterThanOrEqualTo] - field >= value
  /// - [isLessThan] - field < value
  /// - [isLessThanOrEqualTo] - field <= value
  ///
  /// Range operators:
  /// - [isBetween] - value1 <= field <= value2
  /// - [isNotBetween] - field < value1 OR field > value2
  ///
  /// Collection operators:
  /// - [isIn] - field IN (value1, value2, ...)
  /// - [isNotIn] - field NOT IN (value1, value2, ...)
  ///
  /// String operators:
  /// - [contains] - field contains substring
  /// - [startsWith] - field starts with prefix
  /// - [endsWith] - field ends with suffix
  /// - [matches] - field matches regex pattern
  ///
  /// Null operators:
  /// - [isNull] - field IS NULL
  /// - [isNotNull] - field IS NOT NULL
  ///
  /// Array operators (for array/list fields):
  /// - [arrayContains] - array field contains value
  /// - [arrayContainsAny] - array field contains any of values
  ///
  /// Throws:
  /// - [StorageOperationException] if multiple operators provided
  /// - [StorageUnsupportedException] if operator not supported
  ///
  /// Example:
  /// ```dart
  /// query
  ///   .where('age', isGreaterThan: 18, isLessThan: 65)  // AND
  ///   .where('name', contains: 'john', isCaseSensitive: false);
  /// ```
  EntityQuery<T> where(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    List<Object?>? isBetween,
    List<Object?>? isNotBetween,
    List<Object?>? isIn,
    List<Object?>? isNotIn,
    String? contains,
    String? startsWith,
    String? endsWith,
    String? matches,
    bool? isNull,
    bool? isNotNull,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    bool isCaseSensitive = true,
  });

  /// Combines filters with OR logic.
  ///
  /// Creates a group of conditions connected by OR.
  ///
  /// Example:
  /// ```dart
  /// query.or([
  ///   (q) => q.where('role', isEqualTo: 'admin'),
  ///   (q) => q.where('role', isEqualTo: 'moderator'),
  /// ]);
  /// ```
  EntityQuery<T> or(List<EntityQuery<T> Function(EntityQuery<T>)> conditions);

  /// Adds a custom filter condition.
  ///
  /// For complex conditions not expressible with standard operators.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if custom filters not supported
  EntityQuery<T> whereCustom(bool Function(T entity) predicate);

  // ============================================================================
  // SORTING
  // ============================================================================

  /// Sorts results by the specified field.
  ///
  /// Multiple calls add secondary, tertiary, etc. sort fields.
  ///
  /// Parameters:
  /// - [field] - Field name to sort by
  /// - [descending] - Sort direction (default: false = ascending)
  /// - [nullsFirst] - Whether null values appear first (default: false)
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if sorting not supported
  ///
  /// Example:
  /// ```dart
  /// query
  ///   .orderBy('priority', descending: true)
  ///   .orderBy('createdAt', descending: true)
  ///   .orderBy('name');
  /// ```
  EntityQuery<T> orderBy(
    String field, {
    bool descending = false,
    bool nullsFirst = false,
  });

  /// Sorts results by multiple fields at once.
  ///
  /// Alternative to calling [orderBy] multiple times.
  ///
  /// Example:
  /// ```dart
  /// query.orderByMultiple([
  ///   SortField('priority', descending: true),
  ///   SortField('createdAt', descending: true),
  ///   SortField('name'),
  /// ]);
  /// ```
  EntityQuery<T> orderByMultiple(List<SortField> fields);

  // ============================================================================
  // PAGINATION
  // ============================================================================

  /// Limits the number of results returned.
  ///
  /// Parameters:
  /// - [count] - Maximum number of results to return
  ///
  /// Throws:
  /// - [StorageOperationException] if limit is negative
  EntityQuery<T> limit(int count);

  /// Skips the specified number of results.
  ///
  /// Used for offset-based pagination in combination with [limit].
  ///
  /// Parameters:
  /// - [count] - Number of results to skip
  ///
  /// Throws:
  /// - [StorageOperationException] if offset is negative
  ///
  /// Example:
  /// ```dart
  /// // Page 1: offset 0, limit 10
  /// // Page 2: offset 10, limit 10
  /// // Page 3: offset 20, limit 10
  /// ```
  EntityQuery<T> offset(int count);

  /// Starts results after the specified cursor.
  ///
  /// Used for cursor-based pagination (more efficient than offset).
  ///
  /// Parameters:
  /// - [cursor] - Cursor value (typically from previous query result)
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if cursor pagination not supported
  ///
  /// Example:
  /// ```dart
  /// final page1 = await query.limit(10).execute();
  /// final lastCursor = page1.cursor;
  ///
  /// final page2 = await query.startAfterCursor(lastCursor).limit(10).execute();
  /// ```
  EntityQuery<T> startAfterCursor(String cursor);

  /// Starts results at the specified cursor (inclusive).
  ///
  /// Similar to [startAfterCursor] but includes the cursor entity.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if cursor pagination not supported
  EntityQuery<T> startAtCursor(String cursor);

  // ============================================================================
  // PROJECTION (Field Selection)
  // ============================================================================

  /// Selects specific fields to return.
  ///
  /// Only specified fields are populated in returned entities.
  /// Other fields may be null or default values.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if projection not supported
  ///
  /// Example:
  /// ```dart
  /// query.select(['name', 'email', 'age']);
  /// ```
  EntityQuery<T> select(List<String> fields);

  /// Excludes specific fields from results.
  ///
  /// All fields except specified ones are returned.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if projection not supported
  EntityQuery<T> exclude(List<String> fields);

  // ============================================================================
  // GROUPING
  // ============================================================================

  /// Groups results by the specified field(s).
  ///
  /// Used with aggregation functions.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if grouping not supported
  ///
  /// Example:
  /// ```dart
  /// query
  ///   .groupBy(['category', 'status'])
  ///   .aggregate('count', Aggregation.count);
  /// ```
  EntityQuery<T> groupBy(List<String> fields);

  /// Filters grouped results (HAVING clause in SQL).
  ///
  /// Applied after grouping, filters aggregated results.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if having not supported
  ///
  /// Example:
  /// ```dart
  /// query
  ///   .groupBy(['category'])
  ///   .aggregate('totalSales', Aggregation.sum('sales'))
  ///   .having('totalSales', isGreaterThan: 10000);
  /// ```
  EntityQuery<T> having(
    String field, {
    Object? isGreaterThan,
    Object? isLessThan,
    Object? isEqualTo,
  });

  // ============================================================================
  // AGGREGATIONS
  // ============================================================================

  /// Adds an aggregation to the query.
  ///
  /// Aggregations compute summary values:
  /// - [Aggregation.count] - Count entities
  /// - [Aggregation.sum] - Sum field values
  /// - [Aggregation.avg] - Average field values
  /// - [Aggregation.min] - Minimum field value
  /// - [Aggregation.max] - Maximum field value
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if aggregations not supported
  ///
  /// Example:
  /// ```dart
  /// query.aggregate('totalRevenue', Aggregation.sum('price'));
  /// ```
  EntityQuery<T> aggregate(String alias, Aggregation aggregation);

  // ============================================================================
  // JOINS (Optional)
  // ============================================================================

  /// Joins with another entity storage.
  ///
  /// Performs a relational join between entities.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if joins not supported
  ///
  /// Example:
  /// ```dart
  /// query.join(
  ///   orderStorage,
  ///   on: JoinCondition('userId', 'id'),
  ///   type: JoinType.leftOuter,
  /// );
  /// ```
  EntityQuery<T> join<R>(
    dynamic storage, {
    required JoinCondition on,
    JoinType type = JoinType.inner,
  });

  // ============================================================================
  // EXECUTION
  // ============================================================================

  /// Executes the query and returns results.
  ///
  /// Returns a [QueryResult] containing:
  /// - List of entities matching all conditions
  /// - Pagination cursor (if applicable)
  /// - Aggregation results (if any)
  ///
  /// Results are sorted and paginated according to query configuration.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query execution fails
  Future<QueryResult<T>> execute();

  /// Executes the query and returns only the count of matching results.
  ///
  /// More efficient than calling execute().entities.length for large datasets.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query execution fails
  Future<int> count();

  /// Executes the query and returns only the first result.
  ///
  /// Returns the first matching entity or `null` if no matches.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query execution fails
  Future<T?> first();

  /// Executes the query and checks if any results exist.
  ///
  /// Returns `true` if at least one entity matches.
  /// Returns `false` if no entities match.
  ///
  /// More efficient than execute().entities.isNotEmpty for large datasets.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query execution fails
  Future<bool> exists();

  // ============================================================================
  // RAW QUERIES (Escape Hatch)
  // ============================================================================

  /// Executes a raw query in the backend's native language.
  ///
  /// Direct access to backend query capabilities (SQL, etc).
  /// Implementation-specific behavior.
  ///
  /// Parameters:
  /// - [rawQuery] - Backend-specific query string
  /// - [parameters] - Query parameters (if supported)
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized or disposed
  /// - [StorageOperationException] if query fails
  /// - [StorageUnsupportedException] if raw queries not supported
  ///
  /// Warning: Raw queries bypass abstraction safety.
  /// Use only when query DSL is insufficient.
  static Future<List<T>> raw<T>(
    String rawQuery, {
    Map<String, dynamic>? parameters,
  }) {
    throw UnimplementedError('Must be implemented by storage');
  }
}

/// Result of a query execution.
class QueryResult<T> {
  /// List of entities matching the query.
  final List<T> entities;

  /// Cursor for pagination (if cursor-based pagination used).
  final String? cursor;

  /// Aggregation results (if aggregations requested).
  final Map<String, dynamic> aggregations;

  /// Total count of matching entities (if countTotal was requested).
  final int? totalCount;

  /// Query execution time in milliseconds.
  final int? executionTimeMs;

  const QueryResult({
    required this.entities,
    this.cursor,
    this.aggregations = const {},
    this.totalCount,
    this.executionTimeMs,
  });

  /// Number of entities in this result page.
  int get count => entities.length;

  /// Whether there are no entities in this result.
  bool get isEmpty => entities.isEmpty;

  /// Whether there are entities in this result.
  bool get isNotEmpty => entities.isNotEmpty;

  @override
  String toString() => 'QueryResult(count: $count, cursor: $cursor)';
}

/// Sort field specification.
class SortField {
  /// Field name to sort by.
  final String field;

  /// Sort direction.
  final bool descending;

  /// Whether null values appear first.
  final bool nullsFirst;

  const SortField(
    this.field, {
    this.descending = false,
    this.nullsFirst = false,
  });

  @override
  String toString() =>
      '$field ${descending ? 'DESC' : 'ASC'}${nullsFirst ? ' NULLS FIRST' : ''}';
}

/// Aggregation function specification.
class Aggregation {
  /// The aggregation type.
  final AggregationType type;

  /// The field to aggregate (null for COUNT).
  final String? field;

  /// Count of entities.
  const Aggregation.count() : type = AggregationType.count, field = null;

  /// Sum of field values.
  const Aggregation.sum(this.field) : type = AggregationType.sum;

  /// Average of field values.
  const Aggregation.avg(this.field) : type = AggregationType.avg;

  /// Minimum field value.
  const Aggregation.min(this.field) : type = AggregationType.min;

  /// Maximum field value.
  const Aggregation.max(this.field) : type = AggregationType.max;

  @override
  String toString() => '$type${field != null ? '($field)' : '()'}';
}

/// Type of aggregation function.
enum AggregationType { count, sum, avg, min, max }

/// Join condition for relational queries.
class JoinCondition {
  /// Field in the left entity.
  final String leftField;

  /// Field in the right entity.
  final String rightField;

  const JoinCondition(this.leftField, this.rightField);

  @override
  String toString() => '$leftField = $rightField';
}

/// Type of join operation.
enum JoinType {
  /// Inner join - only matching entities.
  inner,

  /// Left outer join - all left entities, matching right entities.
  leftOuter,

  /// Right outer join - all right entities, matching left entities.
  rightOuter,

  /// Full outer join - all entities from both sides.
  fullOuter,
}

/// Query filter for internal use by query builders.
class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;
  final bool isCaseSensitive;

  QueryFilter(
    this.field,
    this.operator,
    this.value, {
    this.isCaseSensitive = true,
  });
}

/// Filter operators for query conditions.
enum FilterOperator {
  equals,
  notEquals,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  between,
  inList,
  notInList,
  contains,
  startsWith,
  endsWith,
  matches,
  isNull,
  isNotNull,
  arrayContains,
  arrayContainsAny,
  custom,
}
