# API Client (Networking)

**Version:** 1.0.0  
**Last Updated:** January 6, 2026  
**Package:** abdalsalam_logic_flutter

---

## Overview

The API Client provides a unified, type-safe interface for HTTP requests with built-in authentication, error handling, and configuration management.

### Key Features

✅ **RESTful Operations** - GET, POST, PUT, PATCH, DELETE  
✅ **Authentication** - Automatic token injection  
✅ **Configuration** - Base URL and default headers  
✅ **Error Handling** - Structured error responses  
✅ **Type-Safe** - Strongly typed responses  

---

## API Reference

### Interface: ApiClient

```dart
abstract class ApiClient extends ServiceInterface {
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  void setBaseUrl(String baseUrl);
  void setAuthToken(String? token);
  void setDefaultHeaders(Map<String, String> headers);
}
```

### Methods

#### get()
```dart
Future<Map<String, dynamic>> get(
  String endpoint, {
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
})
```
Performs a GET request to retrieve data.

**Parameters:**
- `endpoint` - API endpoint (e.g., '/users', '/posts/123')
- `queryParameters` - Optional query string parameters
- `headers` - Optional request headers

**Returns:** Response data as Map

**Example:**
```dart
// Simple GET
final user = await apiClient.get('/users/123');

// GET with query parameters
final users = await apiClient.get(
  '/users',
  queryParameters: {'page': 1, 'limit': 20},
);

// GET with custom headers
final data = await apiClient.get(
  '/protected-resource',
  headers: {'X-Custom-Header': 'value'},
);
```

---

#### post()
```dart
Future<Map<String, dynamic>> post(
  String endpoint, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
})
```
Performs a POST request to create data.

**Parameters:**
- `endpoint` - API endpoint
- `data` - Request body (Map, List, or JSON string)
- `queryParameters` - Optional query parameters
- `headers` - Optional headers

**Returns:** Response data as Map

**Example:**
```dart
// Create user
final newUser = await apiClient.post(
  '/users',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
);

// Login
final response = await apiClient.post(
  '/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);
```

---

#### put()
```dart
Future<Map<String, dynamic>> put(
  String endpoint, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
})
```
Performs a PUT request to replace data.

**Parameters:**
- `endpoint` - API endpoint
- `data` - Complete replacement data
- `queryParameters` - Optional query parameters
- `headers` - Optional headers

**Returns:** Response data as Map

**Example:**
```dart
// Update entire user object
final updatedUser = await apiClient.put(
  '/users/123',
  data: {
    'id': 123,
    'name': 'John Updated',
    'email': 'john.updated@example.com',
    'age': 30,
  },
);
```

---

#### patch()
```dart
Future<Map<String, dynamic>> patch(
  String endpoint, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
})
```
Performs a PATCH request to partially update data.

**Parameters:**
- `endpoint` - API endpoint
- `data` - Partial update data
- `queryParameters` - Optional query parameters
- `headers` - Optional headers

**Returns:** Response data as Map

**Example:**
```dart
// Update only specific fields
final updated = await apiClient.patch(
  '/users/123',
  data: {'name': 'New Name'}, // Only update name
);
```

---

#### delete()
```dart
Future<Map<String, dynamic>> delete(
  String endpoint, {
  Map<String, dynamic>? queryParameters,
  Map<String, String>? headers,
})
```
Performs a DELETE request to remove data.

**Parameters:**
- `endpoint` - API endpoint
- `queryParameters` - Optional query parameters
- `headers` - Optional headers

**Returns:** Response data as Map

**Example:**
```dart
// Delete user
await apiClient.delete('/users/123');

// Delete with confirmation token
await apiClient.delete(
  '/users/123',
  queryParameters: {'confirmation': 'token'},
);
```

---

### Configuration Methods

#### setBaseUrl()
```dart
void setBaseUrl(String baseUrl)
```
Sets the base URL for all API requests.

**Example:**
```dart
apiClient.setBaseUrl('https://api.example.com/v1');

// Now requests use this base:
await apiClient.get('/users'); // -> https://api.example.com/v1/users
```

---

#### setAuthToken()
```dart
void setAuthToken(String? token)
```
Sets the authentication token for requests. Pass `null` to clear.

**Example:**
```dart
// Set token after login
final token = await authService.getAuthToken();
apiClient.setAuthToken(token);

// Clear token on logout
apiClient.setAuthToken(null);
```

---

#### setDefaultHeaders()
```dart
void setDefaultHeaders(Map<String, String> headers)
```
Sets headers that will be included in all requests.

**Example:**
```dart
apiClient.setDefaultHeaders({
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'X-App-Version': '1.0.0',
});
```

---

## Usage Examples

### Example 1: Basic CRUD Operations

```dart
class UserRepository {
  final ApiClient _apiClient;
  
  UserRepository(this._apiClient);
  
  // Create
  Future<User> createUser(User user) async {
    final response = await _apiClient.post(
      '/users',
      data: user.toJson(),
    );
    return User.fromJson(response);
  }
  
  // Read
  Future<User> getUser(int id) async {
    final response = await _apiClient.get('/users/$id');
    return User.fromJson(response);
  }
  
  // Update
  Future<User> updateUser(User user) async {
    final response = await _apiClient.put(
      '/users/${user.id}',
      data: user.toJson(),
    );
    return User.fromJson(response);
  }
  
  // Delete
  Future<void> deleteUser(int id) async {
    await _apiClient.delete('/users/$id');
  }
  
  // List with pagination
  Future<List<User>> getUsers({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      '/users',
      queryParameters: {'page': page, 'limit': limit},
    );
    
    final List<dynamic> data = response['data'];
    return data.map((json) => User.fromJson(json)).toList();
  }
}
```

### Example 2: Authentication Integration

```dart
class ApiService {
  final ApiClient _apiClient;
  final AuthService _authService;
  
  ApiService(this._apiClient, this._authService) {
    _setupAuth();
  }
  
  void _setupAuth() {
    // Set auth token after initialization
    _authService.getAuthToken().then((token) {
      if (token != null) {
        _apiClient.setAuthToken(token);
      }
    });
  }
  
  Future<void> login(String email, String password) async {
    // Login via auth service
    await _authService.signIn(email, password);
    
    // Get token and set it
    final token = await _authService.getAuthToken();
    _apiClient.setAuthToken(token);
  }
  
  Future<void> logout() async {
    // Clear token
    _apiClient.setAuthToken(null);
    
    // Sign out
    await _authService.signOut();
  }
}
```

### Example 3: Error Handling

```dart
class SafeApiClient {
  final ApiClient _apiClient;
  
  SafeApiClient(this._apiClient);
  
  Future<Map<String, dynamic>?> safeGet(String endpoint) async {
    try {
      return await _apiClient.get(endpoint);
    } on NetworkException catch (e) {
      print('Network error: ${e.message}');
      showOfflineDialog();
      return null;
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      navigateToLogin();
      return null;
    } on ApiException catch (e) {
      print('API error: ${e.statusCode} - ${e.message}');
      showErrorDialog(e.message);
      return null;
    } catch (e) {
      print('Unknown error: $e');
      showGenericErrorDialog();
      return null;
    }
  }
}
```

### Example 4: Retry Logic

```dart
class RetryableApiClient {
  final ApiClient _apiClient;
  final int maxRetries;
  
  RetryableApiClient(this._apiClient, {this.maxRetries = 3});
  
  Future<Map<String, dynamic>> getWithRetry(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await _apiClient.get(
          endpoint,
          queryParameters: queryParameters,
        );
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
```

### Example 5: Request Interceptor

```dart
class LoggingApiClient {
  final ApiClient _apiClient;
  final LoggerService _logger;
  
  LoggingApiClient(this._apiClient, this._logger);
  
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final start = DateTime.now();
    _logger.info('GET $endpoint');
    
    try {
      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParameters,
      );
      
      final duration = DateTime.now().difference(start);
      _logger.info('GET $endpoint completed in ${duration.inMilliseconds}ms');
      
      return response;
    } catch (e) {
      _logger.error('GET $endpoint failed: $e');
      rethrow;
    }
  }
}
```

### Example 6: File Upload

```dart
class FileUploadService {
  final ApiClient _apiClient;
  
  FileUploadService(this._apiClient);
  
  Future<String> uploadFile(File file) async {
    // Convert file to base64
    final bytes = await file.readAsBytes();
    final base64File = base64Encode(bytes);
    
    // Upload
    final response = await _apiClient.post(
      '/upload',
      data: {
        'file': base64File,
        'filename': file.path.split('/').last,
        'mimeType': 'image/jpeg',
      },
    );
    
    return response['url'];
  }
}
```

---

## Setup

### 1. Installation

```yaml
# pubspec.yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
  dio: ^5.4.0  # or http: ^1.1.0
```

### 2. Configuration

```dart
import 'package:get_it/get_it.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void setupServices() {
  final getIt = GetIt.instance;
  
  // Register API client
  getIt.registerLazySingleton<ApiClient>(
    () {
      final client = ApiClientImpl(
        logger: getIt<LoggerService>(),
      );
      
      // Configure
      client.setBaseUrl('https://api.example.com/v1');
      client.setDefaultHeaders({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      
      return client;
    },
  );
}
```

### 3. Initialize

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup services
  setupServices();
  
  // Initialize API client
  final apiClient = GetIt.I<ApiClient>();
  await apiClient.initialize();
  
  runApp(MyApp());
}
```

---

## Best Practices

### 1. Use Environment-Specific URLs

✅ **DO**: Switch base URL based on environment
```dart
final baseUrl = kReleaseMode
  ? 'https://api.production.com'
  : 'https://api.staging.com';

apiClient.setBaseUrl(baseUrl);
```

### 2. Handle Token Refresh

✅ **DO**: Refresh expired tokens
```dart
Future<Map<String, dynamic>> get(String endpoint) async {
  try {
    return await _apiClient.get(endpoint);
  } on UnauthorizedException {
    await _authService.refreshToken();
    final newToken = await _authService.getAuthToken();
    _apiClient.setAuthToken(newToken);
    return await _apiClient.get(endpoint); // Retry
  }
}
```

### 3. Use Type-Safe Models

✅ **DO**: Convert responses to models
```dart
Future<User> getUser(int id) async {
  final response = await apiClient.get('/users/$id');
  return User.fromJson(response);
}
```

❌ **DON'T**: Use raw maps everywhere
```dart
final user = await apiClient.get('/users/$id');
print(user['name']); // Error-prone!
```

### 4. Validate Responses

✅ **DO**: Check response structure
```dart
Future<List<User>> getUsers() async {
  final response = await apiClient.get('/users');
  
  if (response['data'] is List) {
    return (response['data'] as List)
      .map((json) => User.fromJson(json))
      .toList();
  }
  
  throw FormatException('Invalid response format');
}
```

### 5. Set Timeouts

✅ **DO**: Configure request timeouts
```dart
final dio = Dio()
  ..options.connectTimeout = Duration(seconds: 10)
  ..options.receiveTimeout = Duration(seconds: 10);
```

---

## Error Types

| Error | Status Code | Cause |
|-------|-------------|-------|
| `NetworkException` | N/A | No internet connection |
| `TimeoutException` | N/A | Request took too long |
| `BadRequestException` | 400 | Invalid request data |
| `UnauthorizedException` | 401 | Invalid/expired token |
| `ForbiddenException` | 403 | Insufficient permissions |
| `NotFoundException` | 404 | Resource not found |
| `ServerException` | 500+ | Server error |

---

## Response Format

### Success Response

```json
{
  "status": "success",
  "data": {
    "id": 123,
    "name": "John Doe"
  }
}
```

### Error Response

```json
{
  "status": "error",
  "message": "User not found",
  "code": "USER_NOT_FOUND"
}
```

### Paginated Response

```json
{
  "status": "success",
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

---

## Summary

The API Client provides:

✅ **RESTful operations** - GET, POST, PUT, PATCH, DELETE  
✅ **Authentication** - Automatic token injection  
✅ **Configuration** - Base URL and headers  
✅ **Error handling** - Structured exceptions  
✅ **Type-safe** - Strong typing throughout  

Use it to build robust, maintainable API integrations in your Flutter app.
