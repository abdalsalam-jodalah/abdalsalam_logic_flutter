// lib/src/prefetch/prefetch_orchestrator.dart
// High-level orchestration for prefetch operations in app initialization

import 'dart:async';

import 'prefetch_paging_config.dart';
import 'prefetch_priority.dart';
import 'prefetch_request.dart';
import 'prefetch_service.dart';
import 'prefetch_status.dart';
import 'prefetch_timing.dart';

class PrefetchOrchestrator {
  final PrefetchService _service;
  final List<PrefetchRequest> _registeredRequests = [];

  PrefetchOrchestrator(this._service);

  Stream<PrefetchStatus> get statusStream => _service.statusStream;

  PrefetchStatus get status => _service.currentStatus;

  PrefetchRequest registerRequest({
    required String url,
    required PrefetchPriority priority,
    required PrefetchTiming timing,
    PrefetchPagingConfig? pagingConfig,
    Duration? delay,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    String? cacheKey,
  }) {
    final request = PrefetchRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      url: url,
      priority: priority,
      timing: timing,
      pagingConfig: pagingConfig,
      delay: delay,
      headers: headers,
      queryParameters: queryParameters,
      cacheKey: cacheKey,
    );

    _registeredRequests.add(request);
    return request;
  }

  Future<void> initialize() async {
    await _service.initialize();
    _service.addRequests(_registeredRequests);
  }

  Future<void> execute() async {
    await _service.execute();
  }

  Future<void> cancel() async {
    await _service.cancelAll();
  }

  void clear() {
    _service.clearCompleted();
    _registeredRequests.clear();
  }

  void dispose() {
    _service.dispose();
    _registeredRequests.clear();
  }
}
