// lib/examples/prefetch_usage_example.dart
// Example usage of PrefetchService in app initialization

import 'dart:async';

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

Future<void> examplePrefetchSetup() async {
  final httpClient = _createHttpClient();
  final executor = PrefetchHttpExecutor(
    httpClient: httpClient,
    timeout: const Duration(seconds: 30),
  );

  final service = PrefetchServiceImpl(executor: executor);
  final orchestrator = PrefetchOrchestrator(service);

  orchestrator.registerRequest(
    url: 'https://api.example.com/users/profile',
    priority: PrefetchPriority.critical,
    timing: PrefetchTiming.duringInit,
    cacheKey: 'user_profile',
  );

  orchestrator.registerRequest(
    url: 'https://api.example.com/dashboard/data',
    priority: PrefetchPriority.normal,
    timing: PrefetchTiming.afterInit,
    cacheKey: 'dashboard_data',
  );

  orchestrator.registerRequest(
    url: 'https://api.example.com/feed/posts',
    priority: PrefetchPriority.normal,
    timing: PrefetchTiming.afterInit,
    pagingConfig: const PrefetchPagingConfig(
      pageSize: 20,
      maxPages: 3,
    ),
    cacheKey: 'feed_posts',
  );

  orchestrator.registerRequest(
    url: 'https://api.example.com/analytics/stats',
    priority: PrefetchPriority.lazy,
    timing: PrefetchTiming.delayed,
    delay: const Duration(seconds: 5),
    cacheKey: 'analytics',
  );

  orchestrator.statusStream.listen((status) {
    if (status.isComplete) {
      _onPrefetchComplete(status);
    }
  });

  await orchestrator.initialize();
  await orchestrator.execute();
}

HttpClient _createHttpClient() {
  return (HttpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const HttpResponse(
      statusCode: 200,
      data: {'success': true, 'message': 'Mock data'},
      headers: {},
    );
  };
}

void _onPrefetchComplete(PrefetchStatus status) {}

Future<void> exampleManualPrefetch() async {
  final httpClient = _createHttpClient();
  final executor = PrefetchHttpExecutor(httpClient: httpClient);
  final service = PrefetchServiceImpl(executor: executor);

  await service.initialize();

  final request = PrefetchRequest(
    id: 'manual_request_1',
    url: 'https://api.example.com/data',
    priority: PrefetchPriority.normal,
    timing: PrefetchTiming.onDemand,
  );

  try {
    final result = await service.executeRequest(request);
    if (result.isSuccess) {
      _handlePrefetchedData(result.data);
    }
  } on PrefetchException catch (e) {
    _handlePrefetchError(e);
  }
}

void _handlePrefetchedData(dynamic data) {}

void _handlePrefetchError(PrefetchException error) {}

Future<void> examplePaginatedPrefetch() async {
  final httpClient = _createHttpClient();
  final executor = PrefetchHttpExecutor(httpClient: httpClient);
  final service = PrefetchServiceImpl(executor: executor);

  await service.initialize();

  final request = PrefetchRequest(
    id: 'paginated_request',
    url: 'https://api.example.com/items',
    priority: PrefetchPriority.normal,
    timing: PrefetchTiming.onDemand,
    pagingConfig: const PrefetchPagingConfig(
      pageSize: 50,
      maxPages: 10,
      pageParamName: 'page',
      pageSizeParamName: 'limit',
      startPage: 1,
    ),
  );

  try {
    final result = await service.executeRequest(request);
    if (result.isSuccess && result.isPaginated) {
      _handlePaginatedData(result.data, result.totalPages, result.currentPage);
    }
  } on PrefetchTimeoutException catch (e) {
    _handleTimeout(e);
  } on PrefetchNetworkException catch (e) {
    _handleNetworkError(e);
  }
}

void _handlePaginatedData(dynamic data, int? totalPages, int? currentPage) {}

void _handleTimeout(PrefetchTimeoutException error) {}

void _handleNetworkError(PrefetchNetworkException error) {}

Future<void> exampleCancellation() async {
  final httpClient = _createHttpClient();
  final executor = PrefetchHttpExecutor(httpClient: httpClient);
  final service = PrefetchServiceImpl(executor: executor);

  await service.initialize();

  final request = PrefetchRequest(
    id: 'cancellable_request',
    url: 'https://api.example.com/large-data',
    priority: PrefetchPriority.normal,
    timing: PrefetchTiming.onDemand,
  );

  service.addRequest(request);

  await Future.delayed(const Duration(milliseconds: 100));

  await service.cancelRequest('cancellable_request');
}
