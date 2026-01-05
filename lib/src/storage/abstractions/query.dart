// lib/src/storage/abstractions/query.dart

import '../exceptions/storage_exceptions.dart';

/// Filter condition for queries.
///
/// Defines a single condition in a query.
/// Implementations should support:
/// - Equality, inequality, comparison operators
/// - Range queries
/// - Text search (if applicable)
/// - Custom predicates
///
/// Generic type [T] is the value type being filtered.
class QueryFilter<T> {
  /// The field name to filter on.
  final String field;

  /// The filter operator.
  final FilterOperator operator;

  /// The value to compare against.
  final Object? value;

  /// Additional filter options.
  final Map<String, dynamic> options;

  QueryFilter({
    required this.field,
    required this.operator,
    this.value,
    this.options = const {},
  });

  /// Creates an equality filter.
  factory QueryFilter.equals(String field, Object value) {
    return QueryFilter(
      field: field,
      operator: FilterOperator.equals,
      value: value,
    );
  }

  /// Creates a not-equal filter.
  factory QueryFilter.notEquals(String field, Object value) {
    return QueryFilter(
      field: field,
      operator: FilterOperator.notEqual,
      value: value,
    );
  }

  /// Creates a greater-than filter.
  factory QueryFilter.greaterThan(String field, Comparable value) {
    return QueryFilter(
      field: field,
      operator: FilterOperator.greaterThan,
      value: value,
    );
  }

  /// Creates a less-than filter.
  factory QueryFilter.lessThan(String field, Comparable value) {
    return QueryFilter(
      field: field,
      operator: FilterOperator.lessThan,
      value: value,
    );
  }

  /// Creates a contains filter (for text search).
  factory QueryFilter.contains(String field, String value) {
    return QueryFilter(
      field: field,
      operator: FilterOperator.contains,
      value: value,
    );
  }

  /// Creates an in filter (value in list).
  factory QueryFilter.inList(String field, List<Object> values) {
    return QueryFilter(
      field: field,
      operator: FilterOperator.inList,
      value: values,
    );
  }

  @override
  String toString() => 'QueryFilter($field $operator $value)';
}

/// Operators for query filters.
enum FilterOperator {
  equals,
  notEqual,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  contains,
  startsWith,
  endsWith,
  inList,
  notInList,
  between,
  isNull,
  isNotNull,
}

/// Sorting configuration for queries.
class QuerySort {
  /// The field name to sort by.
  final String field;

  /// Sort direction (ascending or descending).
  final SortDirection direction;

  QuerySort({
    required this.field,
    this.direction = SortDirection.ascending,
  });

  /// Creates an ascending sort.
  factory QuerySort.ascending(String field) {
    return QuerySort(field: field, direction: SortDirection.ascending);
  }

  /// Creates a descending sort.
  factory QuerySort.descending(String field) {
    return QuerySort(field: field, direction: SortDirection.descending);
  }

  @override
  String toString() => 'QuerySort($field $direction)';
}

/// Sort direction for query results.
enum SortDirection {
  ascending,
  descending,
}

/// Pagination configuration for queries.
class QueryPagination {
  /// Number of results to skip (zero-based offset).
  final int offset;

  /// Maximum number of results to return.
  final int limit;

  QueryPagination({
    required this.offset,
    required this.limit,
  });

  /// Creates pagination for the first page.
  factory QueryPagination.firstPage({
    int pageSize = 20,
  }) {
    return QueryPagination(offset: 0, limit: pageSize);
  }

  /// Creates pagination for a specific page number.
  factory QueryPagination.page({
    required int pageNumber,
    int pageSize = 20,
  }) {
    return QueryPagination(
      offset: (pageNumber - 1) * pageSize,
      limit: pageSize,
    );
  }

  /// Gets the next page pagination.
  QueryPagination nextPage() {
    return QueryPagination(
      offset: offset + limit,
      limit: limit,
    );
  }

  /// Gets the previous page pagination.
  QueryPagination? previousPage() {
    if (offset == 0) return null;
    return QueryPagination(
      offset: (offset - limit).clamp(0, offset),
      limit: limit,
    );
  }

  @override
  String toString() => 'QueryPagination(offset: $offset, limit: $limit)';
}

/// Result of a query operation.
class QueryResult<T> {
  /// The items returned by the query.
  final List<T> items;

  /// Total number of items matching the query (may exceed items.length if paginated).
  final int totalCount;

  /// Pagination used for this query (if any).
  final QueryPagination? pagination;

  /// Query execution time (useful for performance monitoring).
  final Duration? executionTime;

  QueryResult({
    required this.items,
    required this.totalCount,
    this.pagination,
    this.executionTime,
  });

  /// Returns `true` if there are no results.
  bool get isEmpty => items.isEmpty;

  /// Returns `true` if there are results.
  bool get isNotEmpty => items.isNotEmpty;

  /// Returns `true` if there are more pages to fetch.
  bool get hasNextPage {
    if (pagination == null) return false;
    return (pagination!.offset + items.length) < totalCount;
  }

  /// Returns `true` if this is not the first page.
  bool get hasPreviousPage => pagination != null && pagination!.offset > 0;

  @override
  String toString() =>
      'QueryResult(items: ${items.length}/$totalCount, hasNext: $hasNextPage)';
}

/// Abstraction for querying entities in storage.
///
/// Supports advanced query capabilities:
/// - Filtering with multiple conditions
/// - Sorting by one or more fields
/// - Pagination
/// - Field projection (if applicable)
/// - Aggregations (if applicable)
///
/// Generic type [T] is the entity type being queried.
///
/// Implementations may not support all features.
/// Use [supportsFeature] to check capabilities.
abstract class EntityQuery<T> {
  /// Adds a filter condition to this query.
  ///
  /// Multiple filters are combined with AND logic.
  /// Call multiple times to add multiple conditions.
  ///
  /// Returns this query for method chaining.
  EntityQuery<T> where(QueryFilter filter);

  /// Adds an OR filter group.
  ///
  /// All filters passed to [conditions] are ORed together.
  /// Multiple calls to [orWhere] are ANDed with other filters.
  ///
  /// Returns this query for method chaining.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if OR conditions are not supported
  EntityQuery<T> orWhere(List<QueryFilter> conditions);

  /// Adds sorting to this query.
  ///
  /// Call multiple times to sort by multiple fields.
  /// Fields are sorted in the order they're added.
  ///
  /// Returns this query for method chaining.
  EntityQuery<T> orderBy(QuerySort sort);

  /// Sets pagination for this query.
  ///
  /// Overrides any previous pagination setting.
  ///
  /// Returns this query for method chaining.
  EntityQuery<T> paginate(QueryPagination pagination);

  /// Limits the result set to N items.
  ///
  /// Returns this query for method chaining.
  EntityQuery<T> limit(int limit);

  /// Skips the first N results.
  ///
  /// Returns this query for method chaining.
  EntityQuery<T> skip(int count);

  /// Specifies which fields to return (projection).
  ///
  /// Only the specified fields are included in results.
  /// May improve performance by reducing data transfer.
  ///
  /// Returns this query for method chaining.
  ///
  /// Throws:
  /// - [StorageUnsupportedException] if projection is not supported
  EntityQuery<T> select(List<String> fields);

  /// Executes the query and returns all results.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized
  /// - [StorageOperationException] if query execution fails
  /// - [StorageUnsupportedException] if a query feature is not supported
  Future<QueryResult<T>> execute();

  /// Returns a single result from this query.
  ///
  /// If no results match, returns `null`.
  /// If multiple results match, returns the first.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized
  /// - [StorageOperationException] if query execution fails
  /// - [StorageUnsupportedException] if a query feature is not supported
  Future<T?> first();

  /// Counts matching results without fetching them.
  ///
  /// More efficient than [execute] when only count is needed.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized
  /// - [StorageOperationException] if operation fails
  /// - [StorageUnsupportedException] if count is not supported
  Future<int> count();

  /// Checks if any results match this query.
  ///
  /// Returns `true` if at least one result exists, `false` otherwise.
  ///
  /// Throws:
  /// - [StorageStateException] if storage is not initialized
  /// - [StorageOperationException] if operation fails
  Future<bool> exists();

  /// Checks if a feature is supported by this query implementation.
  ///
  /// Features may include: 'filters', 'sorting', 'pagination', 'projection',
  /// 'aggregation', 'or_conditions', etc.
  bool supportsFeature(String feature);

  /// Returns the current query as a string representation.
  ///
  /// Useful for debugging and logging.
  String toQueryString();
}
