// lib/src/prefetch/prefetch_request.dart
// Request model for prefetch operations

import 'prefetch_paging_config.dart';
import 'prefetch_priority.dart';
import 'prefetch_status.dart';
import 'prefetch_timing.dart';

class PrefetchRequest {
  final String id;
  final String url;
  final PrefetchPriority priority;
  final PrefetchTiming timing;
  final PrefetchPagingConfig? pagingConfig;
  final Duration? delay;
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParameters;
  final String? cacheKey;
  final PrefetchRequestStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Object? error;

  const PrefetchRequest({
    required this.id,
    required this.url,
    required this.priority,
    required this.timing,
    this.pagingConfig,
    this.delay,
    this.headers,
    this.queryParameters,
    this.cacheKey,
    this.status = PrefetchRequestStatus.pending,
    this.startedAt,
    this.completedAt,
    this.error,
  });

  PrefetchRequest copyWith({
    String? id,
    String? url,
    PrefetchPriority? priority,
    PrefetchTiming? timing,
    PrefetchPagingConfig? pagingConfig,
    Duration? delay,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? cacheKey,
    PrefetchRequestStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Object? error,
  }) {
    return PrefetchRequest(
      id: id ?? this.id,
      url: url ?? this.url,
      priority: priority ?? this.priority,
      timing: timing ?? this.timing,
      pagingConfig: pagingConfig ?? this.pagingConfig,
      delay: delay ?? this.delay,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      cacheKey: cacheKey ?? this.cacheKey,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      error: error ?? this.error,
    );
  }

  bool get isPaginated => pagingConfig != null;

  bool get isDelayed => timing == PrefetchTiming.delayed && delay != null;

  String getCacheKeyOrDefault() {
    if (cacheKey != null) return cacheKey!;
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}
