// lib/src/storage/implementations/query_builder_impl.dart

import '../abstractions/query_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';

class QueryBuilderImpl<T> implements EntityQuery<T> {
  final List<QueryFilter> _filters = [];
  final List<SortField> _sortFields = [];
  int? _limitCount;
  int? _offsetCount;
  String? _cursorId;
  final List<String> _selectedFields = [];
  final List<String> _excludedFields = [];
  String? _groupByField;

  final Future<List<T>> Function(QueryBuilderImpl<T>) _executor;

  QueryBuilderImpl(this._executor);

  @override
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
  }) {
    if (isEqualTo != null) {
      _filters.add(QueryFilter(field, FilterOperator.equals, isEqualTo));
    }
    if (isNotEqualTo != null) {
      _filters.add(QueryFilter(field, FilterOperator.notEquals, isNotEqualTo));
    }
    if (isGreaterThan != null) {
      _filters.add(
        QueryFilter(field, FilterOperator.greaterThan, isGreaterThan),
      );
    }
    if (isGreaterThanOrEqualTo != null) {
      _filters.add(
        QueryFilter(
          field,
          FilterOperator.greaterThanOrEqual,
          isGreaterThanOrEqualTo,
        ),
      );
    }
    if (isLessThan != null) {
      _filters.add(QueryFilter(field, FilterOperator.lessThan, isLessThan));
    }
    if (isLessThanOrEqualTo != null) {
      _filters.add(
        QueryFilter(field, FilterOperator.lessThanOrEqual, isLessThanOrEqualTo),
      );
    }
    if (isBetween != null) {
      _filters.add(QueryFilter(field, FilterOperator.between, isBetween));
    }
    if (isIn != null) {
      _filters.add(QueryFilter(field, FilterOperator.inList, isIn));
    }
    if (isNotIn != null) {
      _filters.add(QueryFilter(field, FilterOperator.notInList, isNotIn));
    }
    if (contains != null) {
      _filters.add(
        QueryFilter(
          field,
          FilterOperator.contains,
          contains,
          isCaseSensitive: isCaseSensitive,
        ),
      );
    }
    if (startsWith != null) {
      _filters.add(
        QueryFilter(
          field,
          FilterOperator.startsWith,
          startsWith,
          isCaseSensitive: isCaseSensitive,
        ),
      );
    }
    if (endsWith != null) {
      _filters.add(
        QueryFilter(
          field,
          FilterOperator.endsWith,
          endsWith,
          isCaseSensitive: isCaseSensitive,
        ),
      );
    }
    if (matches != null) {
      _filters.add(QueryFilter(field, FilterOperator.matches, matches));
    }
    if (isNull == true) {
      _filters.add(QueryFilter(field, FilterOperator.isNull, null));
    }
    if (isNotNull == true) {
      _filters.add(QueryFilter(field, FilterOperator.isNotNull, null));
    }
    if (arrayContains != null) {
      _filters.add(
        QueryFilter(field, FilterOperator.arrayContains, arrayContains),
      );
    }
    if (arrayContainsAny != null) {
      _filters.add(
        QueryFilter(field, FilterOperator.arrayContainsAny, arrayContainsAny),
      );
    }

    return this;
  }

  @override
  EntityQuery<T> or(List<EntityQuery<T> Function(EntityQuery<T>)> conditions) {
    throw StorageUnsupportedException(
      operation: 'or',
      message: 'OR queries not yet implemented',
    );
  }

  @override
  EntityQuery<T> whereCustom(bool Function(T entity) predicate) {
    _filters.add(QueryFilter('', FilterOperator.custom, predicate));
    return this;
  }

  @override
  EntityQuery<T> orderBy(
    String field, {
    bool descending = false,
    bool nullsFirst = false,
  }) {
    _sortFields.add(
      SortField(field, descending: descending, nullsFirst: nullsFirst),
    );
    return this;
  }

  @override
  EntityQuery<T> orderByMultiple(List<SortField> fields) {
    _sortFields.addAll(fields);
    return this;
  }

  @override
  EntityQuery<T> limit(int count) {
    if (count < 0) {
      throw StorageOperationException(
        operation: 'limit',
        message: 'Limit must be non-negative',
      );
    }
    _limitCount = count;
    return this;
  }

  @override
  EntityQuery<T> offset(int count) {
    if (count < 0) {
      throw StorageOperationException(
        operation: 'offset',
        message: 'Offset must be non-negative',
      );
    }
    _offsetCount = count;
    return this;
  }

  @override
  EntityQuery<T> startAfterCursor(String cursorId) {
    _cursorId = cursorId;
    return this;
  }

  @override
  EntityQuery<T> select(List<String> fields) {
    _selectedFields.addAll(fields);
    return this;
  }

  @override
  EntityQuery<T> exclude(List<String> fields) {
    _excludedFields.addAll(fields);
    return this;
  }

  @override
  EntityQuery<T> groupBy(List<String> fields) {
    if (fields.isNotEmpty) {
      _groupByField = fields.first;
    }
    return this;
  }

  @override
  Future<QueryResult<T>> execute() async {
    final entities = await _executor(this);
    return QueryResult<T>(entities: entities);
  }

  @override
  Future<T?> first() async {
    final result = await limit(1).execute();
    return result.entities.isEmpty ? null : result.entities.first;
  }

  @override
  Future<int> count() async {
    final result = await execute();
    return result.entities.length;
  }

  @override
  Future<bool> exists() async {
    final result = await limit(1).execute();
    return result.entities.isNotEmpty;
  }

  Future<T?> executeFirst() async {
    return await first();
  }

  Future<int> executeCount() async {
    return await count();
  }

  Future<num> sum(String field) async {
    throw StorageUnsupportedException(
      operation: 'sum',
      message: 'Sum aggregation not yet implemented',
    );
  }

  Future<double> avg(String field) async {
    throw StorageUnsupportedException(
      operation: 'avg',
      message: 'Avg aggregation not yet implemented',
    );
  }

  Future<T?> min(String field) async {
    throw StorageUnsupportedException(
      operation: 'min',
      message: 'Min aggregation not yet implemented',
    );
  }

  Future<T?> max(String field) async {
    throw StorageUnsupportedException(
      operation: 'max',
      message: 'Max aggregation not yet implemented',
    );
  }

  @override
  EntityQuery<T> aggregate(String field, Aggregation aggregation) {
    throw StorageUnsupportedException(
      operation: 'aggregate',
      message: 'Aggregation not yet implemented',
    );
  }

  @override
  EntityQuery<T> having(
    String field, {
    Object? isEqualTo,
    Object? isGreaterThan,
    Object? isLessThan,
  }) {
    throw StorageUnsupportedException(
      operation: 'having',
      message: 'Having clause not yet implemented',
    );
  }

  @override
  EntityQuery<T> join<R>(
    dynamic storage, {
    required JoinCondition on,
    JoinType type = JoinType.inner,
  }) {
    throw StorageUnsupportedException(
      operation: 'join',
      message: 'Join not yet implemented',
    );
  }

  @override
  EntityQuery<T> startAtCursor(String cursorId) {
    _cursorId = cursorId;
    return this;
  }

  List<QueryFilter> get filters => List.unmodifiable(_filters);
  List<SortField> get sortFields => List.unmodifiable(_sortFields);
  int? get limitValue => _limitCount;
  int? get offsetValue => _offsetCount;
  String? get cursor => _cursorId;
  List<String> get selectedFields => List.unmodifiable(_selectedFields);
  List<String> get excludedFields => List.unmodifiable(_excludedFields);
  String? get groupByField => _groupByField;
}
