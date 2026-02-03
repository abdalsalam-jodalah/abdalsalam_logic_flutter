// lib/examples/prefetch_app_integration_example.dart
// Complete example of integrating PrefetchService with app initialization

import 'dart:async';

import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class AppPrefetchConfiguration {
  static PrefetchOrchestrator? _orchestrator;

  static Future<void> setupPrefetch({
    required HttpClient httpClient,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final executor = PrefetchHttpExecutor(
      httpClient: httpClient,
      timeout: timeout,
    );

    final service = PrefetchServiceImpl(executor: executor);
    _orchestrator = PrefetchOrchestrator(service);

    _registerCriticalRequests();
    _registerNormalRequests();
    _registerLazyRequests();

    await _orchestrator!.initialize();
  }

  static void _registerCriticalRequests() {
    _orchestrator!.registerRequest(
      url: '/api/v1/auth/verify',
      priority: PrefetchPriority.critical,
      timing: PrefetchTiming.duringInit,
      cacheKey: 'auth_verification',
    );

    _orchestrator!.registerRequest(
      url: '/api/v1/config/app',
      priority: PrefetchPriority.critical,
      timing: PrefetchTiming.duringInit,
      cacheKey: 'app_config',
    );
  }

  static void _registerNormalRequests() {
    _orchestrator!.registerRequest(
      url: '/api/v1/user/profile',
      priority: PrefetchPriority.normal,
      timing: PrefetchTiming.afterInit,
      cacheKey: 'user_profile',
    );

    _orchestrator!.registerRequest(
      url: '/api/v1/notifications/unread',
      priority: PrefetchPriority.normal,
      timing: PrefetchTiming.afterInit,
      pagingConfig: const PrefetchPagingConfig(
        pageSize: 20,
        maxPages: 1,
      ),
      cacheKey: 'notifications',
    );

    _orchestrator!.registerRequest(
      url: '/api/v1/dashboard/widgets',
      priority: PrefetchPriority.normal,
      timing: PrefetchTiming.afterInit,
      cacheKey: 'dashboard_widgets',
    );
  }

  static void _registerLazyRequests() {
    _orchestrator!.registerRequest(
      url: '/api/v1/analytics/summary',
      priority: PrefetchPriority.lazy,
      timing: PrefetchTiming.delayed,
      delay: const Duration(seconds: 3),
      cacheKey: 'analytics_summary',
    );

    _orchestrator!.registerRequest(
      url: '/api/v1/recommendations',
      priority: PrefetchPriority.lazy,
      timing: PrefetchTiming.delayed,
      delay: const Duration(seconds: 5),
      pagingConfig: const PrefetchPagingConfig(
        pageSize: 10,
        maxPages: 2,
      ),
      cacheKey: 'recommendations',
    );
  }

  static Future<void> executePrefetch() async {
    if (_orchestrator == null) {
      throw PrefetchException(
        message: 'Prefetch not configured. Call setupPrefetch first.',
      );
    }

    try {
      await _orchestrator!.execute();
    } catch (e) {
      throw PrefetchException(
        message: 'Prefetch execution failed',
        originalError: e,
      );
    }
  }

  static Stream<PrefetchStatus> get statusStream {
    if (_orchestrator == null) {
      throw PrefetchException(
        message: 'Prefetch not configured.',
      );
    }
    return _orchestrator!.statusStream;
  }

  static PrefetchStatus get currentStatus {
    if (_orchestrator == null) {
      return PrefetchStatus.initial();
    }
    return _orchestrator!.status;
  }

  static Future<void> cancel() async {
    await _orchestrator?.cancel();
  }

  static void dispose() {
    _orchestrator?.dispose();
    _orchestrator = null;
  }
}

Future<void> main() async {
  final httpClient = _buildHttpClient();

  await AppPrefetchConfiguration.setupPrefetch(httpClient: httpClient);

  AppPrefetchConfiguration.statusStream.listen(
    (status) {},
    onError: (error) {
      if (error is PrefetchException) {}
    },
  );

  await AppPrefetchConfiguration.executePrefetch();
}

HttpClient _buildHttpClient() {
  return (HttpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const HttpResponse(
      statusCode: 200,
      data: {'success': true},
      headers: {},
    );
  };
}
