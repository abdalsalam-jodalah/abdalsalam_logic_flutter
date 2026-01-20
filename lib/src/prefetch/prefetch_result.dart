// lib/src/prefetch/prefetch_result.dart
// Result model for prefetch operations

class PrefetchResult<T> {
  final String requestId;
  final T? data;
  final bool isSuccess;
  final Object? error;
  final DateTime completedAt;
  final int? totalPages;
  final int? currentPage;

  const PrefetchResult({
    required this.requestId,
    required this.isSuccess,
    required this.completedAt,
    this.data,
    this.error,
    this.totalPages,
    this.currentPage,
  });

  factory PrefetchResult.success({
    required String requestId,
    required T data,
    int? totalPages,
    int? currentPage,
  }) {
    return PrefetchResult(
      requestId: requestId,
      data: data,
      isSuccess: true,
      completedAt: DateTime.now(),
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  factory PrefetchResult.failure({
    required String requestId,
    required Object error,
  }) {
    return PrefetchResult(
      requestId: requestId,
      isSuccess: false,
      error: error,
      completedAt: DateTime.now(),
    );
  }

  bool get isPaginated => totalPages != null && currentPage != null;

  bool get hasMorePages {
    if (!isPaginated) return false;
    return currentPage! < totalPages!;
  }
}
