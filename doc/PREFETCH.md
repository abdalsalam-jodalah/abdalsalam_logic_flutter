# Prefetch Service Architecture

## Overview

The Prefetch Service is a self-contained, dependency-free module for fetching data early to improve perceived app performance. It provides priority-based scheduling, timing control, and automatic pagination handling.

## Core Design Principles

### 1. Zero Dependencies
- No dependencies on logging, analytics, or other services
- Self-contained and portable
- Errors are thrown, not logged

### 2. Interface-Based Design
- `PrefetchService` interface for core operations
- `PrefetchExecutor` interface for execution strategies
- Clean separation between orchestration and execution

### 3. Priority-Based Execution
- **Critical**: Must execute immediately (auth, config)
- **Normal**: Standard priority (user data, notifications)
- **Lazy**: Can be deferred (analytics, recommendations)

### 4. Timing Control
- **duringInit**: Execute during app initialization
- **afterInit**: Execute immediately after init completes
- **delayed**: Execute after a specified delay
- **onDemand**: Manual execution only

### 5. Performance Safety
- Non-blocking execution (async/await)
- Request cancellation support
- Timeout protection
- No main thread blocking

## Architecture Components

### Core Types

```
prefetch_priority.dart       - Priority enum (critical/normal/lazy)
prefetch_timing.dart         - Timing enum (duringInit/afterInit/delayed/onDemand)
prefetch_status.dart         - Status tracking and progress
prefetch_paging_config.dart  - Pagination configuration
prefetch_request.dart        - Request model
prefetch_result.dart         - Result model
prefetch_exception.dart      - Exception types
```

### Core Services

```
prefetch_service.dart        - Service interface
prefetch_service_impl.dart   - Service implementation
prefetch_executor.dart       - Execution interface and scheduler
prefetch_http_executor.dart  - HTTP-based executor
prefetch_orchestrator.dart   - High-level orchestration
```

## Usage Patterns

### Basic Setup

```dart
// 1. Create executor with HTTP client
final executor = PrefetchHttpExecutor(
  httpClient: yourHttpClient,
  timeout: const Duration(seconds: 30),
);

// 2. Create service
final service = PrefetchServiceImpl(executor: executor);

// 3. Create orchestrator
final orchestrator = PrefetchOrchestrator(service);

// 4. Register requests
orchestrator.registerRequest(
  url: '/api/user/profile',
  priority: PrefetchPriority.critical,
  timing: PrefetchTiming.duringInit,
  cacheKey: 'user_profile',
);

// 5. Initialize and execute
await orchestrator.initialize();
await orchestrator.execute();
```

### Paginated Requests

```dart
orchestrator.registerRequest(
  url: '/api/feed/posts',
  priority: PrefetchPriority.normal,
  timing: PrefetchTiming.afterInit,
  pagingConfig: const PrefetchPagingConfig(
    pageSize: 20,
    maxPages: 5,
    pageParamName: 'page',
    pageSizeParamName: 'limit',
  ),
  cacheKey: 'feed_posts',
);
```

### Delayed Requests

```dart
orchestrator.registerRequest(
  url: '/api/analytics',
  priority: PrefetchPriority.lazy,
  timing: PrefetchTiming.delayed,
  delay: const Duration(seconds: 5),
  cacheKey: 'analytics',
);
```

### Manual On-Demand Execution

```dart
final request = PrefetchRequest(
  id: 'manual_1',
  url: '/api/data',
  priority: PrefetchPriority.normal,
  timing: PrefetchTiming.onDemand,
);

try {
  final result = await service.executeRequest(request);
  if (result.isSuccess) {
    // Handle data
  }
} on PrefetchException catch (e) {
  // Handle error
}
```

### Status Monitoring

```dart
orchestrator.statusStream.listen((status) {
  print('Progress: ${status.progress * 100}%');
  print('Completed: ${status.completedRequests}/${status.totalRequests}');
  
  if (status.isComplete) {
    print('All prefetch operations completed');
  }
});
```

### Cancellation

```dart
// Cancel specific request
await service.cancelRequest('request_id');

// Cancel all pending requests
await orchestrator.cancel();
```

## Data Storage Integration

The Prefetch Service does NOT manage its own storage. It fetches data and returns it to the caller. The caller is responsible for storing data using the app's existing storage mechanism (e.g., `StorageGateway`).

**Recommended Pattern:**

```dart
// In your app initialization
final result = await service.executeRequest(request);
if (result.isSuccess) {
  // Store using your app's storage system
  await StorageGateway.instance.saveEntity(
    key: request.getCacheKeyOrDefault(),
    data: result.data,
  );
}
```

## Error Handling

All errors are thrown as `PrefetchException` or its subtypes:

- `PrefetchException` - Base exception
- `PrefetchNetworkException` - Network failures
- `PrefetchStorageException` - Storage failures  
- `PrefetchCancelledException` - Request cancelled
- `PrefetchTimeoutException` - Request timeout

**Pattern:**

```dart
try {
  await orchestrator.execute();
} on PrefetchTimeoutException catch (e) {
  // Handle timeout
} on PrefetchNetworkException catch (e) {
  // Handle network error
} on PrefetchException catch (e) {
  // Handle general error
}
```

## HTTP Client Integration

The service requires an HTTP client following this signature:

```dart
typedef HttpClient = Future<HttpResponse> Function(HttpRequest request);
```

**Integration with Dio:**

```dart
HttpClient buildDioClient(Dio dio) {
  return (HttpRequest request) async {
    try {
      final response = await dio.get(
        request.url,
        queryParameters: request.queryParameters,
        options: Options(headers: request.headers),
      );
      
      return HttpResponse(
        statusCode: response.statusCode ?? 500,
        data: response.data,
        headers: response.headers.map.map(
          (k, v) => MapEntry(k, v.join(', ')),
        ),
      );
    } catch (e) {
      rethrow;
    }
  };
}
```

## Execution Flow

### During Initialization

```
1. Register all requests via orchestrator
2. Call orchestrator.initialize()
   - Service initializes
   - Requests are added to scheduler
3. Call orchestrator.execute()
   - duringInit requests execute first (sorted by priority)
   - afterInit requests execute second (sorted by priority)
   - delayed requests are scheduled
4. Monitor via statusStream
```

### Priority Sorting

Requests are executed in this order:
1. Critical priority
2. Normal priority
3. Lazy priority

Within each priority level, execution order is first-registered, first-executed.

### Pagination Flow

For paginated requests:
1. First page fetched
2. Response checked for more data
3. Next page fetched if available
4. Continue until maxPages or no more data
5. All pages merged into single result

## Performance Considerations

### Memory
- Paginated requests accumulate data in memory
- Use `maxPages` to limit memory usage
- Clear completed requests: `service.clearCompleted()`

### Network
- Parallel execution within same priority
- Sequential execution across priorities
- Timeout protection (default 30s)

### Thread Safety
- All operations are async
- No main thread blocking
- Use isolates for heavy processing if needed

## Testing

### Unit Testing

```dart
test('executes critical requests first', () async {
  final mockExecutor = MockPrefetchExecutor();
  final service = PrefetchServiceImpl(executor: mockExecutor);
  
  final critical = PrefetchRequest(/*...*/);
  final normal = PrefetchRequest(/*...*/);
  
  service.addRequests([normal, critical]);
  await service.execute();
  
  verify(mockExecutor.execute(critical)).called(1);
  verify(mockExecutor.execute(normal)).called(1);
});
```

### Integration Testing

```dart
testWidgets('prefetch completes before app renders', (tester) async {
  final orchestrator = setupPrefetchOrchestrator();
  
  await orchestrator.initialize();
  final executeFuture = orchestrator.execute();
  
  await tester.pumpWidget(MyApp());
  await executeFuture;
  
  expect(orchestrator.status.isComplete, true);
});
```

## Best Practices

### 1. Minimize Critical Requests
Only mark truly essential data as critical (auth, config).

### 2. Use Lazy Priority for Analytics
Non-user-facing data should be lazy priority.

### 3. Set Reasonable Timeouts
Balance between reliability and user experience.

### 4. Limit Pagination
Use `maxPages` to prevent excessive data fetching.

### 5. Handle Errors Gracefully
App should function even if prefetch fails.

### 6. Monitor Progress
Use `statusStream` for user feedback if needed.

### 7. Dispose Properly
Call `orchestrator.dispose()` when done.

## Migration from Existing Systems

If you have existing prefetch logic:

1. Identify all data fetched during initialization
2. Classify by priority (critical/normal/lazy)
3. Classify by timing (duringInit/afterInit/delayed)
4. Create `PrefetchRequest` for each
5. Register with orchestrator
6. Replace old logic with `orchestrator.execute()`

## Future Enhancements

Potential additions (not currently implemented):

- Retry strategies with exponential backoff
- Request deduplication
- Cache validation (If-None-Match, ETag)
- Background refresh
- Network type awareness (WiFi vs cellular)
- Storage quota management
- Request prioritization adjustment at runtime

## API Reference

See individual file headers for detailed API documentation:

- [prefetch_service.dart](../src/prefetch/prefetch_service.dart)
- [prefetch_orchestrator.dart](../src/prefetch/prefetch_orchestrator.dart)
- [prefetch_request.dart](../src/prefetch/prefetch_request.dart)
- [prefetch_result.dart](../src/prefetch/prefetch_result.dart)
