// lib/src/storage/implementations/queryable_storage_mixin.dart

import 'dart:async';
import '../abstractions/entity_storage_comprehensive.dart';
import '../abstractions/query_comprehensive.dart';
import '../exceptions/storage_exceptions.dart';
import 'query_builder_impl.dart';

mixin QueryableStorageMixin<ID, T> on EntityStorage<ID, T> {
  Future<EntityQuery<T>> createQuery() async {
    if (!isInitialized || isDisposed) {
      throw StorageStateException(
        message: 'Storage not initialized or disposed',
      );
    }

    return QueryBuilderImpl<T>(_executeQuery);
  }

  Future<List<T>> _executeQuery(QueryBuilderImpl<T> query) async {
    try {
      var results = await getAll();

      for (final filter in query.filters) {
        results = _applyFilter(results, filter);
      }

      if (query.sortFields.isNotEmpty) {
        results = _applySorting(results, query.sortFields);
      }

      if (query.offsetValue != null && query.offsetValue! > 0) {
        results = results.skip(query.offsetValue!).toList();
      }

      if (query.limitValue != null && query.limitValue! > 0) {
        results = results.take(query.limitValue!).toList();
      }

      return results;
    } catch (e) {
      throw StorageOperationException(
        operation: 'executeQuery',
        message: 'Failed to execute query: $e',
      );
    }
  }

  List<T> _applyFilter(List<T> entities, QueryFilter filter) {
    if (filter.operator == FilterOperator.custom) {
      final predicate = filter.value as bool Function(T);
      return entities.where(predicate).toList();
    }

    return entities.where((entity) {
      final fieldValue = _getFieldValue(entity, filter.field);

      switch (filter.operator) {
        case FilterOperator.equals:
          return fieldValue == filter.value;
        case FilterOperator.notEquals:
          return fieldValue != filter.value;
        case FilterOperator.greaterThan:
          return _compareValues(fieldValue, filter.value) > 0;
        case FilterOperator.greaterThanOrEqual:
          return _compareValues(fieldValue, filter.value) >= 0;
        case FilterOperator.lessThan:
          return _compareValues(fieldValue, filter.value) < 0;
        case FilterOperator.lessThanOrEqual:
          return _compareValues(fieldValue, filter.value) <= 0;
        case FilterOperator.between:
          final range = filter.value as List;
          return _compareValues(fieldValue, range[0]) >= 0 &&
              _compareValues(fieldValue, range[1]) <= 0;
        case FilterOperator.inList:
          final list = filter.value as List;
          return list.contains(fieldValue);
        case FilterOperator.notInList:
          final list = filter.value as List;
          return !list.contains(fieldValue);
        case FilterOperator.contains:
          if (fieldValue is String && filter.value is String) {
            final str = filter.isCaseSensitive
                ? fieldValue
                : fieldValue.toLowerCase();
            final search = filter.isCaseSensitive
                ? filter.value as String
                : (filter.value as String).toLowerCase();
            return str.contains(search);
          }
          return false;
        case FilterOperator.startsWith:
          if (fieldValue is String && filter.value is String) {
            final str = filter.isCaseSensitive
                ? fieldValue
                : fieldValue.toLowerCase();
            final search = filter.isCaseSensitive
                ? filter.value as String
                : (filter.value as String).toLowerCase();
            return str.startsWith(search);
          }
          return false;
        case FilterOperator.endsWith:
          if (fieldValue is String && filter.value is String) {
            final str = filter.isCaseSensitive
                ? fieldValue
                : fieldValue.toLowerCase();
            final search = filter.isCaseSensitive
                ? filter.value as String
                : (filter.value as String).toLowerCase();
            return str.endsWith(search);
          }
          return false;
        case FilterOperator.matches:
          if (fieldValue is String && filter.value is String) {
            return RegExp(filter.value as String).hasMatch(fieldValue);
          }
          return false;
        case FilterOperator.isNull:
          return fieldValue == null;
        case FilterOperator.isNotNull:
          return fieldValue != null;
        case FilterOperator.arrayContains:
          if (fieldValue is List) {
            return fieldValue.contains(filter.value);
          }
          return false;
        case FilterOperator.arrayContainsAny:
          if (fieldValue is List && filter.value is List) {
            final searchList = filter.value as List;
            return searchList.any((item) => fieldValue.contains(item));
          }
          return false;
        case FilterOperator.custom:
          // This should never be reached as we handle custom at the top
          return true;
      }
    }).toList();
  }

  List<T> _applySorting(List<T> entities, List<SortField> sortFields) {
    final sorted = List<T>.from(entities);

    sorted.sort((a, b) {
      for (final sortField in sortFields) {
        final aValue = _getFieldValue(a, sortField.field);
        final bValue = _getFieldValue(b, sortField.field);

        if (aValue == null && bValue == null) continue;
        if (aValue == null) return sortField.nullsFirst ? -1 : 1;
        if (bValue == null) return sortField.nullsFirst ? 1 : -1;

        final comparison = _compareValues(aValue, bValue);
        if (comparison != 0) {
          return sortField.descending ? -comparison : comparison;
        }
      }
      return 0;
    });

    return sorted;
  }

  dynamic _getFieldValue(T entity, String field) {
    try {
      final map = _entityToMap(entity);
      return map[field];
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> _entityToMap(T entity) {
    if (entity is Map<String, dynamic>) {
      return entity;
    }

    try {
      final json = (entity as dynamic).toJson();
      if (json is Map<String, dynamic>) {
        return json;
      }
    } catch (e) {
      // Silently ignore JSON decode errors
    }

    return {};
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    if (a is Comparable && b is Comparable) {
      return a.compareTo(b);
    }

    return 0;
  }
}
