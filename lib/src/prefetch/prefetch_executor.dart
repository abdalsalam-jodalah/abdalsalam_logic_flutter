// lib/src/prefetch/prefetch_executor.dart
// Execution strategy for prefetch requests based on priority and timing

import 'dart:async';

import 'prefetch_priority.dart';
import 'prefetch_request.dart';
import 'prefetch_result.dart';
import 'prefetch_timing.dart';

abstract class PrefetchExecutor {
  Future<PrefetchResult> execute(PrefetchRequest request);

  Future<void> cancel(String requestId);
}

class PrefetchScheduler {
  final Map<String, Timer> _scheduledTimers = {};
  final Map<PrefetchPriority, List<PrefetchRequest>> _priorityQueues = {
    PrefetchPriority.critical: [],
    PrefetchPriority.normal: [],
    PrefetchPriority.lazy: [],
  };

  void schedule(
    PrefetchRequest request,
    Future<void> Function(PrefetchRequest) executor,
  ) {
    if (request.timing == PrefetchTiming.delayed && request.delay != null) {
      _scheduledTimers[request.id] = Timer(request.delay!, () {
        _scheduledTimers.remove(request.id);
        executor(request);
      });
    } else {
      _priorityQueues[request.priority]?.add(request);
    }
  }

  List<PrefetchRequest> getRequestsByTiming(PrefetchTiming timing) {
    final requests = <PrefetchRequest>[];
    for (final queue in _priorityQueues.values) {
      requests.addAll(queue.where((r) => r.timing == timing));
    }
    return _sortByPriority(requests);
  }

  List<PrefetchRequest> getAllPendingRequests() {
    final requests = <PrefetchRequest>[];
    for (final queue in _priorityQueues.values) {
      requests.addAll(queue);
    }
    return _sortByPriority(requests);
  }

  void removeRequest(String requestId) {
    _scheduledTimers[requestId]?.cancel();
    _scheduledTimers.remove(requestId);
    for (final queue in _priorityQueues.values) {
      queue.removeWhere((r) => r.id == requestId);
    }
  }

  void clear() {
    for (final timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
    for (final queue in _priorityQueues.values) {
      queue.clear();
    }
  }

  List<PrefetchRequest> _sortByPriority(List<PrefetchRequest> requests) {
    final sorted = List<PrefetchRequest>.from(requests);
    sorted.sort((a, b) {
      final priorityOrder = {
        PrefetchPriority.critical: 0,
        PrefetchPriority.normal: 1,
        PrefetchPriority.lazy: 2,
      };
      return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
    });
    return sorted;
  }
}
