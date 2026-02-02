// lib/src/prefetch/prefetch_http_executor.dart
// HTTP-based executor for prefetch requests (requires HTTP client injection)

import 'dart:async';
import 'dart:convert';

import 'prefetch_exception.dart';
import 'prefetch_executor.dart';
import 'prefetch_request.dart';
import 'prefetch_result.dart';

typedef HttpClient = Future<HttpResponse> Function(HttpRequest request);

class HttpRequest {
  final String url;
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParameters;

  const HttpRequest({
    required this.url,
    this.headers,
    this.queryParameters,
  });
}

class HttpResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, String> headers;

  const HttpResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class PrefetchHttpExecutor implements PrefetchExecutor {
  final HttpClient httpClient;
  final Map<String, Completer<void>> _activeRequests = {};
  final Duration timeout;

  PrefetchHttpExecutor({
    required this.httpClient,
    this.timeout = const Duration(seconds: 30),
  });

  @override
  Future<PrefetchResult> execute(PrefetchRequest request) async {
    if (_activeRequests.containsKey(request.id)) {
      throw PrefetchException(
        message: 'Request already in progress',
        requestId: request.id,
      );
    }

    final completer = Completer<void>();
    _activeRequests[request.id] = completer;

    try {
      if (request.isPaginated) {
        return await _executePaginatedRequest(request);
      } else {
        return await _executeSingleRequest(request);
      }
    } finally {
      _activeRequests.remove(request.id);
      if (!completer.isCompleted) completer.complete();
    }
  }

  @override
  Future<void> cancel(String requestId) async {
    final completer = _activeRequests[requestId];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        PrefetchCancelledException(
          message: 'Request cancelled',
          requestId: requestId,
        ),
      );
    }
    _activeRequests.remove(requestId);
  }

  Future<PrefetchResult> _executeSingleRequest(
    PrefetchRequest request,
  ) async {
    try {
      final httpRequest = HttpRequest(
        url: request.url,
        headers: request.headers,
        queryParameters: request.queryParameters,
      );

      final response = await httpClient(httpRequest).timeout(timeout);

      if (!response.isSuccess) {
        throw PrefetchNetworkException(
          message: 'HTTP ${response.statusCode}',
          requestId: request.id,
        );
      }

      return PrefetchResult.success(
        requestId: request.id,
        data: response.data,
      );
    } on TimeoutException {
      throw PrefetchTimeoutException(
        message: 'Request timed out',
        timeout: timeout,
        requestId: request.id,
      );
    } catch (e, stack) {
      throw PrefetchNetworkException(
        message: 'Network request failed',
        requestId: request.id,
        originalError: e,
        stackTrace: stack,
      );
    }
  }

  Future<PrefetchResult> _executePaginatedRequest(
    PrefetchRequest request,
  ) async {
    final config = request.pagingConfig!;
    final allData = <dynamic>[];
    int currentPage = config.startPage;
    final maxPages = config.maxPages ?? 999;

    try {
      while (currentPage < config.startPage + maxPages) {
        final params = Map<String, dynamic>.from(
          request.queryParameters ?? {},
        );
        params[config.pageParamName] = currentPage;
        params[config.pageSizeParamName] = config.pageSize;

        final httpRequest = HttpRequest(
          url: request.url,
          headers: request.headers,
          queryParameters: params,
        );

        final response = await httpClient(httpRequest).timeout(timeout);

        if (!response.isSuccess) {
          throw PrefetchNetworkException(
            message: 'HTTP ${response.statusCode} on page $currentPage',
            requestId: request.id,
          );
        }

        final pageData = response.data;
        if (pageData is List) {
          allData.addAll(pageData);
          if (pageData.length < config.pageSize) break;
        } else if (pageData is Map && pageData.containsKey('items')) {
          final items = pageData['items'] as List;
          allData.addAll(items);
          if (items.length < config.pageSize) break;
        } else {
          allData.add(pageData);
          break;
        }

        currentPage++;
      }

      return PrefetchResult.success(
        requestId: request.id,
        data: allData,
        totalPages: currentPage - config.startPage,
        currentPage: currentPage,
      );
    } on TimeoutException {
      throw PrefetchTimeoutException(
        message: 'Paginated request timed out at page $currentPage',
        timeout: timeout,
        requestId: request.id,
      );
    } catch (e, stack) {
      if (e is PrefetchException) rethrow;
      throw PrefetchNetworkException(
        message: 'Paginated request failed at page $currentPage',
        requestId: request.id,
        originalError: e,
        stackTrace: stack,
      );
    }
  }
}
