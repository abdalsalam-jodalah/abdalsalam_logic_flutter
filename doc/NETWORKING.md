# Networking System Documentation

**Version:** 2.0.0  
**Last Updated:** February 2, 2026  
**Package:** abdalsalam_logic_flutter

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Core Components](#core-components)
  - [Network API Registry](#network-api-registry)
  - [Request Manager](#request-manager)
  - [Network API Interface](#network-api-interface)
  - [Authentication Provider](#authentication-provider)
  - [Status Code Strategies](#status-code-strategies)
- [Getting Started](#getting-started)
- [API Definition](#api-definition)
- [Request Execution](#request-execution)
- [Offline & Queue Management](#offline--queue-management)
- [Authentication Handling](#authentication-handling)
- [Error Handling](#error-handling)
- [Configuration Options](#configuration-options)
- [Best Practices](#best-practices)
- [Examples](#examples)

---

## Overview

The Networking System provides a comprehensive, offline-first HTTP client architecture for Flutter applications. It enforces API registration, supports priority-based offline queuing, handles authentication with automatic token refresh, and provides flexible backend response patterns.

### Key Features

🔐 **Registration-First Architecture** - All APIs must be explicitly registered before execution  
🌐 **Offline-First Design** - Automatic request queuing when offline, processing when reconnected  
🔑 **Authentication Management** - Automatic token injection, refresh, and failure handling  
📊 **Priority-Based Queue** - Intelligent request ordering with priority levels  
🎯 **Flexible Backend Support** - Multiple status code strategies for different API patterns  
🛡️ **Robust Error Handling** - Typed exceptions with detailed error information  
📱 **Connectivity Awareness** - Real-time online/offline detection and response  
🔧 **Enable/Disable Control** - Runtime control over request execution  
📈 **Real-Time Monitoring** - Queue count streams and connectivity status  

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter Application                         │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ execute<TReq, TRes>()
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Request Manager                               │
│  • Single execution gateway                                     │
│  • Enable/disable control                                       │
│  • Offline detection & queuing                                  │
│  • Auth retry logic                                             │
│  • Error conversion                                             │
└─────────┬───────────────────────┬─────────────────────┬─────────┘
          │                       │                     │
          ▼                       ▼                     ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Network Registry│    │ Auth Provider   │    │ App State Mgr   │
│ • API validation│    │ • Token refresh │    │ • Connectivity  │
│ • Registration  │    │ • Failure hdlng │    │ • State streams │
│ • Lookup        │    │ • Access tokens │    │ • Online detect │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Persistent Queue Storage                       │
│  • Hive-based storage                                           │
│  • Priority sorting                                             │
│  • Retry counting                                               │
│  • Survives app restart                                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core Components

### Network API Registry

The **Network API Registry** is a mandatory registration system where every API must be explicitly registered before it can be executed. This ensures API consistency and prevents runtime errors.

```dart
abstract class NetworkRegistry extends ServiceInterface {
  void register<T extends NetworkApi>(T api);
  T? getApi<T extends NetworkApi>();
  List<NetworkApi> listApis();
  bool isRegistered<T extends NetworkApi>();
  void unregister<T extends NetworkApi>();
  void clear();
}
```

**Key Features:**
- **Mandatory Registration** - APIs must be registered before execution
- **Duplicate Prevention** - Prevents registering the same API type multiple times
- **Validation** - Validates API definitions during registration
- **Type Safety** - Generic type-safe API retrieval

### Request Manager

The **Request Manager** serves as the single execution gateway for all network requests. No request can bypass this component.

```dart
abstract class RequestManager extends ServiceInterface {
  Future<NetworkResponse<TResponse>> execute<TRequest, TResponse>(
    NetworkApi<TRequest, TResponse> api,
  );
  
  void enable();
  void disable();
  bool get isEnabled;
  
  Future<void> processQueue();
  Future<int> getPendingCount();
  Future<void> clearQueue();
  
  Stream<int> get queueCountStream;
}
```

**Key Features:**
- **Single Gateway** - All requests must go through this manager
- **Enable/Disable Control** - Runtime control over request execution
- **Queue Management** - Priority-based offline request queuing
- **Real-Time Monitoring** - Stream-based queue count updates
- **Connectivity Integration** - Automatic processing when back online

### Network API Interface

All APIs must extend the `NetworkApi<TRequest, TResponse>` abstract class:

```dart
abstract class NetworkApi<TRequest, TResponse> {
  String get apiTypeIdentifier;        // Unique identifier
  HttpMethod get method;               // HTTP method
  ApiUrl get urlObject;                // URL configuration
  TRequest? get bodyModel;             // Request body model
  bool get needAuth;                   // Authentication required
  bool get queueFlag;                  // Queue when offline
  int get priority;                    // Execution priority
  bool get cacheFlag;                  // Cache metadata
  
  Map<String, dynamic>? toRequestBody();
  TResponse parseResponse(Map<String, dynamic> responseData);
  Map<String, String> getHeaders() => {};
}
```

### Authentication Provider

Optional authentication abstraction for handling tokens:

```dart
abstract class AuthTokenProvider {
  Future<String?> getAccessToken();
  Future<String?> refreshToken();
  Future<void> onAuthFailure();
}
```

### Status Code Strategies

Support for different backend response patterns:

```dart
abstract class StatusCodeStrategy {
  bool isSuccess(int? httpStatus, Map<String, dynamic>? responseBody);
  String? getInternalStatus(Map<String, dynamic>? responseBody);
  String? getErrorMessage(int? httpStatus, Map<String, dynamic>? responseBody);
}
```

**Available Strategies:**
- **HttpStatusCodeStrategy** - HTTP status is authoritative (RESTful APIs)
- **InternalStatusCodeStrategy** - HTTP 200 + internal status field

---

## Getting Started

### 1. Basic Setup

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

// Initialize components
final registry = NetworkRegistryImpl();
final appStateManager = AppStateManagerImpl.create();
final requestManager = RequestManagerImpl(
  registry: registry,
  appStateManager: appStateManager,
);

// Initialize services
await registry.initialize();
await appStateManager.initialize();
await requestManager.initialize();
```

### 2. With Authentication

```dart
// Create auth provider
final authProvider = MyAuthProvider();

final requestManager = RequestManagerImpl(
  registry: registry,
  appStateManager: appStateManager,
  authTokenProvider: authProvider,
  statusCodeStrategy: InternalStatusCodeStrategy(),
);
```

### 3. Register APIs

```dart
// Register your APIs before use
registry.register(GetUserApi(1));
registry.register(CreateUserApi(CreateUserRequest(
  name: 'John Doe',
  email: 'john@example.com',
)));
```

---

## API Definition

### Define Data Models

```dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}

class CreateUserRequest {
  final String name;
  final String email;

  CreateUserRequest({required this.name, required this.email});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
  };
}
```

### Create API Classes

#### GET Request Example

```dart
class GetUserApi extends NetworkApi<void, User> {
  final int userId;

  GetUserApi(this.userId);

  @override
  String get apiTypeIdentifier => 'get_user';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  ApiUrl get urlObject => ApiUrl(
    baseUrl: 'https://api.example.com',
    path: '/users/{userId}',
    pathVariables: {'userId': userId.toString()},
  );

  @override
  void get bodyModel => null;

  @override
  bool get needAuth => false;

  @override
  bool get queueFlag => true;      // Queue when offline

  @override
  int get priority => 0;           // Normal priority

  @override
  bool get cacheFlag => true;      // Enable caching

  @override
  Map<String, dynamic>? toRequestBody() => null;

  @override
  User parseResponse(Map<String, dynamic> responseData) {
    return User.fromJson(responseData['data'] ?? responseData);
  }
}
```

#### POST Request Example

```dart
class CreateUserApi extends NetworkApi<CreateUserRequest, User> {
  final CreateUserRequest request;

  CreateUserApi(this.request);

  @override
  String get apiTypeIdentifier => 'create_user';

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  ApiUrl get urlObject => const ApiUrl(
    baseUrl: 'https://api.example.com',
    path: '/users',
  );

  @override
  CreateUserRequest get bodyModel => request;

  @override
  bool get needAuth => true;       // Requires authentication

  @override
  bool get queueFlag => true;      // Queue when offline

  @override
  int get priority => 1;           // Higher priority

  @override
  bool get cacheFlag => false;     // Don't cache POST responses

  @override
  Map<String, dynamic> toRequestBody() => request.toJson();

  @override
  User parseResponse(Map<String, dynamic> responseData) {
    return User.fromJson(responseData['data'] ?? responseData);
  }

  @override
  Map<String, String> getHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### URL Configuration

The `ApiUrl` class supports dynamic URLs:

```dart
// Static URL
ApiUrl(
  baseUrl: 'https://api.example.com',
  path: '/users',
)

// Path variables
ApiUrl(
  baseUrl: 'https://api.example.com',
  path: '/users/{userId}/posts/{postId}',
  pathVariables: {
    'userId': '123',
    'postId': '456',
  },
)

// Query parameters
ApiUrl(
  baseUrl: 'https://api.example.com',
  path: '/users',
  queryParameters: {
    'page': 1,
    'limit': 20,
    'sort': 'name',
  },
)

// Runtime base URL changes
final api = GetUserApi(123);
final newUrl = api.urlObject.copyWith(
  baseUrl: 'https://staging-api.example.com',
);
```

---

## Request Execution

### Basic Execution

```dart
try {
  final getUserApi = GetUserApi(123);
  final response = await requestManager.execute(getUserApi);
  
  if (response.isSuccess) {
    final user = response.parsedModel!;
    print('User: ${user.name}');
    
    // Access additional response data
    print('HTTP Status: ${response.httpStatus}');
    print('Internal Status: ${response.internalStatus}');
    print('Raw Response: ${response.rawResponse}');
  } else {
    print('Error: ${response.error}');
  }
} catch (e) {
  // Handle exceptions
  print('Exception: $e');
}
```

### Response Object

The `NetworkResponse<T>` provides comprehensive response information:

```dart
class NetworkResponse<T> {
  final int? httpStatus;              // HTTP status code
  final String? internalStatus;       // Internal status (if using internal strategy)
  final T? parsedModel;               // Parsed response model
  final Map<String, dynamic>? rawResponse;  // Raw response data
  final String? error;                // Error message (if failed)
  final bool isSuccess;               // Success flag
}
```

### Error Handling

```dart
try {
  final response = await requestManager.execute(api);
  // Handle response...
} on NetworkManagerDisabledException catch (e) {
  // Request manager is disabled
  print('Manager disabled: ${e.message}');
} on NetworkUnregisteredApiException catch (e) {
  // API not registered
  print('Unregistered API: ${e.message}');
} on NetworkAuthFailedException catch (e) {
  // Authentication failed
  print('Auth failed: ${e.message}');
} on NetworkTimeoutException catch (e) {
  // Request timeout
  print('Timeout: ${e.message}');
} on NetworkOfflineException catch (e) {
  // Device offline
  print('Offline: ${e.message}');
} on NetworkBackendException catch (e) {
  // Server error
  print('Server error: ${e.message}');
} catch (e) {
  // Unexpected error
  print('Unexpected: $e');
}
```

---

## Offline & Queue Management

### Automatic Queuing

When the device goes offline, requests with `queueFlag = true` are automatically queued:

```dart
class ImportantApi extends NetworkApi<void, Data> {
  @override
  bool get queueFlag => true;  // Queue when offline
  
  @override
  int get priority => 5;       // High priority
  
  // ... other implementation
}
```

### Queue Monitoring

```dart
// Listen to queue count changes
requestManager.queueCountStream.listen((count) {
  print('Pending requests: $count');
  // Update UI badge or indicator
});

// Get current queue count
final count = await requestManager.getPendingCount();
print('Current queue: $count');
```

### Manual Queue Management

```dart
// Process queue manually (usually automatic)
await requestManager.processQueue();

// Clear all pending requests
await requestManager.clearQueue();

// Temporarily disable request processing
requestManager.disable();

// Re-enable request processing
requestManager.enable();
```

### Priority System

```dart
// Higher numbers = higher priority
class CriticalApi extends NetworkApi<void, Data> {
  @override
  int get priority => 10;      // Highest priority
}

class NormalApi extends NetworkApi<void, Data> {
  @override
  int get priority => 0;       // Normal priority
}

class LowPriorityApi extends NetworkApi<void, Data> {
  @override
  int get priority => -5;      // Low priority
}
```

**Queue Processing Order:**
1. Higher priority first (10 → 5 → 1 → 0 → -1 → -5)
2. Same priority → FIFO (first in, first out)
3. Retry failed requests with exponential backoff

---

## Authentication Handling

### Implement Auth Provider

```dart
class MyAuthProvider implements AuthTokenProvider {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  @override
  Future<String?> refreshToken() async {
    if (_refreshToken == null) return null;
    
    try {
      // Make API call to refresh token
      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': _refreshToken,
      });
      
      _accessToken = response.data['access_token'];
      return _accessToken;
    } catch (e) {
      return null; // Refresh failed
    }
  }

  @override
  Future<void> onAuthFailure() async {
    // Clear tokens
    _accessToken = null;
    _refreshToken = null;
    
    // Navigate to login screen
    Navigator.pushReplacementNamed(context, '/login');
    
    // Or show login dialog
    // showLoginDialog();
  }
}
```

### Auth-Required APIs

```dart
class ProfileApi extends NetworkApi<void, Profile> {
  @override
  bool get needAuth => true;   // Requires authentication
  
  @override
  bool get queueFlag => true;  // Queue for retry after auth refresh
  
  // ... other implementation
}
```

### Auth Flow

1. Request with `needAuth = true` is executed
2. Access token is automatically attached via `Authorization: Bearer <token>`
3. If server returns 401 (Unauthorized):
   - `refreshToken()` is called automatically
   - If refresh succeeds → request is retried with new token
   - If refresh fails → `onAuthFailure()` is called

---

## Error Handling

### Exception Hierarchy

```dart
// Base network exception
NetworkException

// Specific exceptions
├── NetworkTimeoutException        // Connection timeout
├── NetworkOfflineException        // Device offline/connection error  
├── NetworkManagerDisabledException // Request manager disabled
├── NetworkBackendException        // Server error (4xx, 5xx)
├── NetworkAuthFailedException     // Authentication failure
├── NetworkValidationException     // API validation error
└── NetworkUnregisteredApiException // API not registered
```

### Comprehensive Error Handling

```dart
Future<User?> fetchUser(int userId) async {
  try {
    final api = GetUserApi(userId);
    final response = await requestManager.execute(api);
    
    if (response.isSuccess) {
      return response.parsedModel;
    } else {
      // Handle business logic errors
      logger.warning('User fetch failed: ${response.error}');
      showSnackBar('Failed to load user: ${response.error}');
      return null;
    }
    
  } on NetworkTimeoutException catch (e) {
    logger.error('Timeout fetching user: ${e.message}');
    showSnackBar('Request timed out. Please try again.');
    return null;
    
  } on NetworkOfflineException catch (e) {
    logger.info('Offline, request queued: ${e.message}');
    showSnackBar('You are offline. Request will be sent when connected.');
    return null;
    
  } on NetworkAuthFailedException catch (e) {
    logger.error('Auth failed: ${e.message}');
    // onAuthFailure() already called automatically
    return null;
    
  } on NetworkUnregisteredApiException catch (e) {
    logger.error('API not registered: ${e.message}');
    // This should not happen in production
    return null;
    
  } catch (e, stackTrace) {
    logger.error('Unexpected error: $e', stackTrace);
    showSnackBar('An unexpected error occurred');
    return null;
  }
}
```

---

## Configuration Options

### Status Code Strategies

#### HTTP Status Strategy (RESTful APIs)

```dart
final requestManager = RequestManagerImpl(
  registry: registry,
  appStateManager: appStateManager,
  statusCodeStrategy: HttpStatusCodeStrategy(), // Default
);
```

**Behavior:**
- 200-299 = Success
- 400+ = Error
- Error messages extracted from response body

#### Internal Status Strategy (Custom APIs)

```dart
final requestManager = RequestManagerImpl(
  registry: registry,
  appStateManager: appStateManager,
  statusCodeStrategy: InternalStatusCodeStrategy(
    statusField: 'status',                    // Field containing status
    messageField: 'message',                  // Field containing error message
    successStatuses: ['success', 'ok'],       // Values indicating success
  ),
);
```

**Example Response:**
```json
{
  "status": "success",
  "message": "User created successfully",
  "data": {
    "id": 123,
    "name": "John Doe"
  }
}
```

### Custom Storage

```dart
final customStorage = MyPendingRequestStorage();

final requestManager = RequestManagerImpl(
  registry: registry,
  appStateManager: appStateManager,
  pendingRequestStorage: customStorage,
);
```

### Dio Configuration

The Request Manager uses Dio internally. You can access configuration via inheritance:

```dart
class CustomRequestManager extends RequestManagerImpl {
  CustomRequestManager({...}) : super(...);
  
  @override
  void _initializeDio() {
    super._initializeDio();
    
    // Customize Dio settings
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    
    // Add interceptors
    _dio.interceptors.add(LogInterceptor());
  }
}
```

---

## Best Practices

### 1. API Design

```dart
// ✅ Good: Descriptive identifier
class GetUserProfileApi extends NetworkApi<void, UserProfile> {
  @override
  String get apiTypeIdentifier => 'get_user_profile';
}

// ❌ Bad: Generic identifier
class UserApi extends NetworkApi<void, User> {
  @override
  String get apiTypeIdentifier => 'user';
}
```

### 2. Priority Assignment

```dart
// ✅ Good: Logical priorities
class LoginApi extends NetworkApi<LoginRequest, LoginResponse> {
  @override
  int get priority => 10;         // Highest - user action
  @override
  bool get queueFlag => false;    // Don't queue login
}

class GetMessagesApi extends NetworkApi<void, List<Message>> {
  @override
  int get priority => 5;          // High - core content
  @override
  bool get queueFlag => true;     // Queue for offline sync
}

class GetAnalyticsApi extends NetworkApi<void, Analytics> {
  @override
  int get priority => -5;         // Low - non-critical
  @override
  bool get queueFlag => false;    // Don't queue analytics
}
```

### 3. Error Messages

```dart
// ✅ Good: User-friendly error handling
try {
  final response = await requestManager.execute(api);
  // ...
} on NetworkTimeoutException catch (e) {
  showUserMessage('Connection timed out. Please check your internet connection.');
} on NetworkAuthFailedException catch (e) {
  showUserMessage('Session expired. Please log in again.');
}

// ❌ Bad: Technical error exposure
catch (e) {
  showUserMessage(e.toString()); // Shows technical details
}
```

### 4. Queue Management

```dart
// ✅ Good: Monitor queue for user feedback
void setupQueueMonitoring() {
  requestManager.queueCountStream.listen((count) {
    if (count > 0) {
      showOfflineBanner('$count requests pending sync');
    } else {
      hideOfflineBanner();
    }
  });
}

// ✅ Good: Clear queue on logout
Future<void> logout() async {
  await requestManager.clearQueue();  // Clear user-specific requests
  await authProvider.clearTokens();
  navigateToLogin();
}
```

### 5. API Registration

```dart
// ✅ Good: Register once, reuse instances
class ApiRegistry {
  static final getUserApi = GetUserApi(0);     // Template instance
  static final createUserApi = CreateUserApi(CreateUserRequest(name: '', email: ''));
  
  static void registerAll(NetworkRegistry registry) {
    registry.register(getUserApi);
    registry.register(createUserApi);
    // ... register all APIs
  }
}

// Usage: Create new instances for different parameters
final specificUserApi = GetUserApi(userId);
```

### 6. Testing

```dart
// ✅ Good: Mock for testing
class MockRequestManager implements RequestManager {
  @override
  Future<NetworkResponse<T>> execute<T, R>(NetworkApi<T, R> api) async {
    // Return mock responses based on API type
    if (api.apiTypeIdentifier == 'get_user') {
      return NetworkResponse.success(data: mockUser);
    }
    return NetworkResponse.failure(error: 'Mock error');
  }
  
  // ... implement other methods
}
```

---

## Examples

### Complete Setup Example

```dart
class NetworkingService {
  late final NetworkRegistry _registry;
  late final RequestManager _requestManager;
  late final AppStateManager _appStateManager;
  late final MyAuthProvider _authProvider;
  
  StreamSubscription<int>? _queueSubscription;
  StreamSubscription<AppStateInfo>? _connectivitySubscription;

  Future<void> initialize() async {
    // 1. Create components
    _registry = NetworkRegistryImpl();
    _appStateManager = AppStateManagerImpl.create();
    _authProvider = MyAuthProvider();
    
    // 2. Create request manager
    _requestManager = RequestManagerImpl(
      registry: _registry,
      appStateManager: _appStateManager,
      authTokenProvider: _authProvider,
      statusCodeStrategy: InternalStatusCodeStrategy(),
    );

    // 3. Initialize services
    await _registry.initialize();
    await _appStateManager.initialize();
    await _requestManager.initialize();

    // 4. Register APIs
    _registerAPIs();

    // 5. Setup monitoring
    _setupMonitoring();
  }

  void _registerAPIs() {
    _registry.register(LoginApi(LoginRequest(email: '', password: '')));
    _registry.register(GetUserApi(0));
    _registry.register(CreateUserApi(CreateUserRequest(name: '', email: '')));
    _registry.register(UpdateUserApi(0, UpdateUserRequest()));
    _registry.register(DeleteUserApi(0));
    // ... register all your APIs
  }

  void _setupMonitoring() {
    // Monitor queue changes
    _queueSubscription = _requestManager.queueCountStream.listen((count) {
      if (count > 0) {
        NotificationService.showSyncPending(count);
      } else {
        NotificationService.hideSyncPending();
      }
    });

    // Monitor connectivity
    _connectivitySubscription = _appStateManager.stateStream.listen((state) {
      if (state.isOnline) {
        NotificationService.showOnline();
      } else {
        NotificationService.showOffline();
      }
    });
  }

  // High-level API methods
  Future<User?> getUser(int userId) async {
    try {
      final api = GetUserApi(userId);
      final response = await _requestManager.execute(api);
      return response.isSuccess ? response.parsedModel : null;
    } on NetworkException catch (e) {
      _handleNetworkError(e);
      return null;
    }
  }

  Future<User?> createUser(String name, String email) async {
    try {
      final api = CreateUserApi(CreateUserRequest(name: name, email: email));
      final response = await _requestManager.execute(api);
      return response.isSuccess ? response.parsedModel : null;
    } on NetworkException catch (e) {
      _handleNetworkError(e);
      return null;
    }
  }

  void _handleNetworkError(NetworkException error) {
    switch (error.runtimeType) {
      case NetworkTimeoutException:
        SnackBarService.show('Connection timeout. Please try again.');
        break;
      case NetworkOfflineException:
        SnackBarService.show('You are offline. Request will sync when connected.');
        break;
      case NetworkAuthFailedException:
        // Auth provider already handled this
        break;
      default:
        SnackBarService.show('Network error: ${error.message}');
    }
  }

  Future<void> dispose() async {
    await _queueSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _requestManager.dispose();
    await _appStateManager.dispose();
    await _registry.dispose();
  }
}
```

### Usage in Widget

```dart
class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final NetworkingService _networkingService = GetIt.instance();
  User? _user;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _networkingService.getUser(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadUser,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(child: Text('User not found'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Text('Name: ${_user!.name}'),
          Text('Email: ${_user!.email}'),
          // ... other user details
        ],
      ),
    );
  }
}
```

---

## Additional Resources

- **Examples**: See `lib/examples/networking_*.dart` for complete examples
- **Demo**: Run the example app and try "🌐 Networking Demo"
- **Source Code**: Check `lib/src/networking/` for implementation details
- **Issues**: Report issues on GitHub with networking logs

---

**For more detailed examples and interactive demos, see the examples folder and run the demo application.**
