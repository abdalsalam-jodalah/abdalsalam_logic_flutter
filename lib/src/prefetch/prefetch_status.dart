// lib/src/prefetch/prefetch_status.dart
// Status tracking for prefetch operations

enum PrefetchRequestStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

class PrefetchStatus {
  final int totalRequests;
  final int completedRequests;
  final int failedRequests;
  final int pendingRequests;
  final bool isComplete;

  const PrefetchStatus({
    required this.totalRequests,
    required this.completedRequests,
    required this.failedRequests,
    required this.pendingRequests,
    required this.isComplete,
  });

  factory PrefetchStatus.initial() {
    return const PrefetchStatus(
      totalRequests: 0,
      completedRequests: 0,
      failedRequests: 0,
      pendingRequests: 0,
      isComplete: true,
    );
  }

  double get progress {
    if (totalRequests == 0) return 0.0;
    return completedRequests / totalRequests;
  }
}
