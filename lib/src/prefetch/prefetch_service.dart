// lib/src/prefetch/prefetch_service.dart
// Interface for prefetch service operations

import 'dart:async';

import 'prefetch_request.dart';
import 'prefetch_result.dart';
import 'prefetch_status.dart';

abstract class PrefetchService {
  Stream<PrefetchStatus> get statusStream;

  PrefetchStatus get currentStatus;

  Future<void> initialize();

  Future<void> execute();

  void addRequest(PrefetchRequest request);

  void addRequests(List<PrefetchRequest> requests);

  Future<PrefetchResult> executeRequest(PrefetchRequest request);

  Future<void> cancelRequest(String requestId);

  Future<void> cancelAll();

  void clearCompleted();

  void dispose();
}
