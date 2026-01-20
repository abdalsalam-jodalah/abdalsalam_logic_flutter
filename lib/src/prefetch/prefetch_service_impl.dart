// lib/src/prefetch/prefetch_service_impl.dart
// Implementation of prefetch service with priority-based execution

import 'dart:async';

import 'prefetch_exception.dart';
import 'prefetch_executor.dart';
import 'prefetch_request.dart';
import 'prefetch_result.dart';
import 'prefetch_service.dart';
import 'prefetch_status.dart';
import 'prefetch_timing.dart';

class PrefetchServiceImpl implements PrefetchService {
  final PrefetchExecutor executor;
  final PrefetchScheduler _scheduler = PrefetchScheduler();
  final Map<String, PrefetchRequest> _requests = {};
  final Map<String, PrefetchResult> _results = {};
  final StreamController<PrefetchStatus> _statusController =
      StreamController<PrefetchStatus>.broadcast();

  bool _isInitialized = false;
  bool _isExecuting = false;

  PrefetchServiceImpl({required this.executor});

  @override
  Stream<PrefetchStatus> get statusStream => _statusController.stream;

  @override
  PrefetchStatus get currentStatus {
    final total = _requests.length;
    final completed = _requests.values
        .where((r) => r.status == PrefetchRequestStatus.completed)
        .length;
    final failed = _requests.values
        .where((r) => r.status == PrefetchRequestStatus.failed)
        .length;
    final pending = _requests.values
        .where((r) => r.status == PrefetchRequestStatus.pending)
        .length;

    return PrefetchStatus(
      totalRequests: total,
      completedRequests: completed,
      failedRequests: failed,
      pendingRequests: pending,
      isComplete: pending == 0 && !_isExecuting,
    );
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      throw PrefetchException(message: 'Service already initialized');
    }
    _isInitialized = true;
  }

  @override
  Future<void> execute() async {
    if (!_isInitialized) {
      throw PrefetchException(message: 'Service not initialized');
    }

    if (_isExecuting) {
      throw PrefetchException(message: 'Execution already in progress');
    }

    _isExecuting = true;
    _emitStatus();

    try {
      await _executeByTiming(PrefetchTiming.duringInit);
      await _executeByTiming(PrefetchTiming.afterInit);
      await _executeByTiming(PrefetchTiming.delayed);
    } finally {
      _isExecuting = false;
      _emitStatus();
    }
  }

  @override
  void addRequest(PrefetchRequest request) {
    if (_requests.containsKey(request.id)) {
      throw PrefetchException(
        message: 'Request with id ${request.id} already exists',
        requestId: request.id,
      );
    }

    _requests[request.id] = request;
    _scheduler.schedule(request, _executeRequestInternal);
    _emitStatus();
  }

  @override
  void addRequests(List<PrefetchRequest> requests) {
    for (final request in requests) {
      addRequest(request);
    }
  }

  @override
  Future<PrefetchResult> executeRequest(PrefetchRequest request) async {
    if (!_isInitialized) {
      throw PrefetchException(message: 'Service not initialized');
    }

    if (!_requests.containsKey(request.id)) {
      addRequest(request);
    }

    return await _executeRequestInternal(request);
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    final request = _requests[requestId];
    if (request == null) return;

    await executor.cancel(requestId);
    _scheduler.removeRequest(requestId);

    final cancelled = request.copyWith(
      status: PrefetchRequestStatus.cancelled,
      completedAt: DateTime.now(),
    );
    _requests[requestId] = cancelled;
    _emitStatus();
  }

  @override
  Future<void> cancelAll() async {
    final requestIds = List<String>.from(_requests.keys);
    for (final id in requestIds) {
      await cancelRequest(id);
    }
  }

  @override
  void clearCompleted() {
    _requests.removeWhere(
      (_, r) =>
          r.status == PrefetchRequestStatus.completed ||
          r.status == PrefetchRequestStatus.cancelled,
    );
    _results.clear();
    _emitStatus();
  }

  @override
  void dispose() {
    _scheduler.clear();
    _statusController.close();
    _requests.clear();
    _results.clear();
  }

  Future<void> _executeByTiming(PrefetchTiming timing) async {
    final requests = _scheduler.getRequestsByTiming(timing);

    for (final request in requests) {
      if (request.status == PrefetchRequestStatus.pending) {
        await _executeRequestInternal(request);
      }
    }
  }

  Future<PrefetchResult> _executeRequestInternal(
    PrefetchRequest request,
  ) async {
    final startedRequest = request.copyWith(
      status: PrefetchRequestStatus.inProgress,
      startedAt: DateTime.now(),
    );
    _requests[request.id] = startedRequest;
    _emitStatus();

    try {
      final result = await executor.execute(request);
      _results[request.id] = result;

      final completedRequest = request.copyWith(
        status: PrefetchRequestStatus.completed,
        completedAt: result.completedAt,
      );
      _requests[request.id] = completedRequest;
      _scheduler.removeRequest(request.id);
      _emitStatus();

      return result;
    } catch (e) {
      final failedRequest = request.copyWith(
        status: PrefetchRequestStatus.failed,
        completedAt: DateTime.now(),
        error: e,
      );
      _requests[request.id] = failedRequest;
      _scheduler.removeRequest(request.id);
      _emitStatus();

      rethrow;
    }
  }

  void _emitStatus() {
    if (!_statusController.isClosed) {
      _statusController.add(currentStatus);
    }
  }
}
