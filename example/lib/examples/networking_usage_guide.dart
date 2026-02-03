// lib/examples/networking_usage_guide.dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

/// Complete guide showing how to use the networking system step by step
class NetworkingUsageGuide {
  
  /// Step 1: Define your data models
  /// These models represent your request/response data
  void step1_DefineModels() {
    /*
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
    */
  }
  
  /// Step 2: Create API definitions by extending NetworkApi<TRequest, TResponse>
  /// Each API must be defined as a class before use
  void step2_DefineAPIs() {
    /*
    class GetUserApi extends NetworkApi<void, User> {
      final int userId;
    
      GetUserApi(this.userId);
    
      @override
      String get apiTypeIdentifier => 'get_user';  // Unique identifier
    
      @override
      HttpMethod get method => HttpMethod.get;
    
      @override
      ApiUrl get urlObject => ApiUrl(
        baseUrl: 'https://api.example.com',
        path: '/users/{userId}',
        pathVariables: {'userId': userId.toString()},
      );
    
      @override
      void get bodyModel => null;  // GET requests typically have no body
    
      @override
      bool get needAuth => false;  // Set to true if authentication required
    
      @override
      bool get queueFlag => true;  // Queue this request when offline
    
      @override
      int get priority => 0;  // Higher number = higher priority
    
      @override
      bool get cacheFlag => true;  // Metadata for future caching
    
      @override
      Map<String, dynamic>? toRequestBody() => null;
    
      @override
      User parseResponse(Map<String, dynamic> responseData) {
        // Parse the response data into your model
        return User.fromJson(responseData['data'] ?? responseData);
      }
    }
    
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
      bool get needAuth => true;  // This requires authentication
    
      @override
      bool get queueFlag => true;
    
      @override
      int get priority => 1;  // Higher priority than GET requests
    
      @override
      bool get cacheFlag => false;  // Don't cache POST responses
    
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
    */
  }
  
  /// Step 3: Set up authentication provider (optional, only if you have auth APIs)
  void step3_SetupAuthProvider() {
    /*
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
        
        // Make API call to refresh token
        // This is typically a separate API call
        try {
          // final response = await dio.post('/auth/refresh', data: {'refresh_token': _refreshToken});
          // _accessToken = response.data['access_token'];
          // return _accessToken;
          
          // For demo purposes:
          _accessToken = 'new_token_${DateTime.now().millisecondsSinceEpoch}';
          return _accessToken;
        } catch (e) {
          return null;
        }
      }
    
      @override
      Future<void> onAuthFailure() async {
        // Called when auth fails - clear tokens, navigate to login, etc.
        _accessToken = null;
        _refreshToken = null;
        
        // Example: Navigate to login screen
        // Navigator.pushReplacementNamed(context, '/login');
      }
    }
    */
  }
  
  /// Step 4: Initialize the networking system
  Future<void> step4_InitializeSystem() async {
    /*
    // Create required components
    final registry = NetworkRegistryImpl();
    final appStateManager = AppStateManagerImpl.create();
    final authProvider = MyAuthProvider();  // Optional
    
    // Create request manager with optional auth and status strategy
    final requestManager = RequestManagerImpl(
      registry: registry,
      appStateManager: appStateManager,
      authTokenProvider: authProvider,  // Optional
      statusCodeStrategy: HttpStatusCodeStrategy(),  // or InternalStatusCodeStrategy()
    );
    
    // Initialize all components
    await registry.initialize();
    await appStateManager.initialize();
    await requestManager.initialize();
    
    // Register your APIs (REQUIRED before use)
    registry.register(GetUserApi(1));
    registry.register(CreateUserApi(CreateUserRequest(
      name: 'John Doe',
      email: 'john@example.com',
    )));
    */
  }
  
  /// Step 5: Execute requests
  Future<void> step5_ExecuteRequests() async {
    /*
    try {
      // Example 1: Simple GET request
      final getUserApi = GetUserApi(123);
      final userResponse = await requestManager.execute(getUserApi);
      
      if (userResponse.isSuccess) {
        final user = userResponse.parsedModel!;
        print('User: ${user.name} (${user.email})');
      } else {
        print('Error: ${userResponse.error}');
      }
      
      // Example 2: POST request with authentication
      final createUserApi = CreateUserApi(CreateUserRequest(
        name: 'Jane Doe',
        email: 'jane@example.com',
      ));
      final createResponse = await requestManager.execute(createUserApi);
      
      if (createResponse.isSuccess) {
        final newUser = createResponse.parsedModel!;
        print('Created user: ${newUser.id}');
      } else {
        print('Creation failed: ${createResponse.error}');
      }
      
    } on NetworkManagerDisabledException catch (e) {
      print('Request manager is disabled: ${e.message}');
    } on NetworkUnregisteredApiException catch (e) {
      print('API not registered: ${e.message}');
    } on NetworkAuthFailedException catch (e) {
      print('Authentication failed: ${e.message}');
    } on NetworkTimeoutException catch (e) {
      print('Request timed out: ${e.message}');
    } on NetworkOfflineException catch (e) {
      print('Device is offline: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
    */
  }
  
  /// Step 6: Handle offline scenarios and queue management
  Future<void> step6_OfflineHandling() async {
    /*
    // Listen to queue changes
    requestManager.queueCountStream.listen((count) {
      print('Pending requests in queue: $count');
    });
    
    // When device goes offline, requests with queueFlag=true are automatically queued
    // When device comes back online, the queue is automatically processed
    
    // Manual queue management:
    
    // Get current queue count
    final queueCount = await requestManager.getPendingCount();
    print('Queue count: $queueCount');
    
    // Manually process queue (usually not needed, auto-processed on reconnect)
    await requestManager.processQueue();
    
    // Clear queue (remove all pending requests)
    await requestManager.clearQueue();
    
    // Temporarily disable request manager
    requestManager.disable();
    
    // Re-enable request manager
    requestManager.enable();
    */
  }
  
  /// Step 7: Status code strategies for different backends
  void step7_StatusCodeStrategies() {
    /*
    // Strategy A: HTTP status is authoritative (most RESTful APIs)
    final httpStrategy = HttpStatusCodeStrategy();
    // - 200-299 = success, anything else = failure
    // - Error messages extracted from response body
    
    // Strategy B: Always HTTP 200, but with internal status field
    final internalStrategy = InternalStatusCodeStrategy(
      statusField: 'status',        // Field containing internal status
      messageField: 'message',      // Field containing error message
      successStatuses: ['success', 'ok'],  // Values indicating success
    );
    
    // Use the appropriate strategy when creating RequestManager:
    final requestManager = RequestManagerImpl(
      registry: registry,
      appStateManager: appStateManager,
      statusCodeStrategy: httpStrategy,  // or internalStrategy
    );
    */
  }
  
  /// Step 8: Best practices and tips
  void step8_BestPractices() {
    /*
    // 1. API Registration
    // - Always register APIs before use
    // - Use descriptive apiTypeIdentifier values
    // - Register once, use many times
    
    // 2. Priority Management
    // - Higher numbers = higher priority
    // - Same priority = FIFO order
    // - Use negative priorities for low-priority requests
    
    // 3. Queue Management
    // - Set queueFlag=true for important requests
    // - Set queueFlag=false for real-time requests (like login)
    // - Monitor queue count to show user feedback
    
    // 4. Error Handling
    // - Always handle specific NetworkException types
    // - Use try-catch blocks around execute() calls
    // - Check response.isSuccess before using parsedModel
    
    // 5. Authentication
    // - Implement AuthTokenProvider for auth-required APIs
    // - Handle token refresh in refreshToken() method
    // - Clear tokens in onAuthFailure()
    
    // 6. Testing
    // - Mock NetworkRegistry and RequestManager for unit tests
    // - Test offline scenarios by disabling RequestManager
    // - Test auth failures by returning null from getAccessToken()
    
    // 7. Performance
    // - Reuse API instances when possible
    // - Don't create new APIs for every request
    // - Use appropriate priority values
    // - Set cacheFlag for future caching implementations
    */
  }
}

/// Example of complete setup in a real app
class RealWorldExample {
  late NetworkRegistry _registry;
  late RequestManager _requestManager;
  late AppStateManager _appStateManager;
  
  Future<void> setupNetworking() async {
    // 1. Initialize components
    _registry = NetworkRegistryImpl();
    _appStateManager = AppStateManagerImpl.create();
    
    // 2. Set up with auth provider and status strategy
    final authProvider = MyAuthProvider();
    _requestManager = RequestManagerImpl(
      registry: _registry,
      appStateManager: _appStateManager,
      authTokenProvider: authProvider,
      statusCodeStrategy: InternalStatusCodeStrategy(),
    );
    
    // 3. Initialize everything
    await _registry.initialize();
    await _appStateManager.initialize();
    await _requestManager.initialize();
    
    // 4. Register all your APIs
    _registerAPIs();
    
    // 5. Set up listeners
    _setupListeners();
  }
  
  void _registerAPIs() {
    // Register all APIs your app will use
    _registry.register(GetUserApi(1));
    _registry.register(CreateUserApi(CreateUserRequest(name: '', email: '')));
    // ... register other APIs
  }
  
  void _setupListeners() {
    // Listen to queue changes for UI feedback
    _requestManager.queueCountStream.listen((count) {
      // Update UI badge or indicator
    });
    
    // Listen to connectivity changes
    _appStateManager.stateStream.listen((state) {
      if (state.isOnline) {
        // Show online indicator
      } else {
        // Show offline indicator
      }
    });
  }
  
  Future<void> dispose() async {
    await _requestManager.dispose();
    await _appStateManager.dispose();
    await _registry.dispose();
  }
}

// Placeholder classes for the example
class User {
  final int id;
  final String name;
  final String email;
  User({required this.id, required this.name, required this.email});
  factory User.fromJson(Map<String, dynamic> json) => User(id: 0, name: '', email: '');
}

class CreateUserRequest {
  final String name;
  final String email;
  CreateUserRequest({required this.name, required this.email});
  Map<String, dynamic> toJson() => {};
}

class GetUserApi extends NetworkApi<void, User> {
  final int userId;
  GetUserApi(this.userId);
  @override String get apiTypeIdentifier => 'get_user';
  @override HttpMethod get method => HttpMethod.get;
  @override ApiUrl get urlObject => ApiUrl(baseUrl: '', path: '');
  @override get bodyModel => null;
  @override bool get needAuth => false;
  @override bool get queueFlag => true;
  @override int get priority => 0;
  @override bool get cacheFlag => false;
  @override Map<String, dynamic>? toRequestBody() => null;
  @override User parseResponse(Map<String, dynamic> responseData) => User.fromJson({});
}

class CreateUserApi extends NetworkApi<CreateUserRequest, User> {
  final CreateUserRequest request;
  CreateUserApi(this.request);
  @override String get apiTypeIdentifier => 'create_user';
  @override HttpMethod get method => HttpMethod.post;
  @override ApiUrl get urlObject => const ApiUrl(baseUrl: '', path: '');
  @override get bodyModel => request;
  @override bool get needAuth => true;
  @override bool get queueFlag => true;
  @override int get priority => 1;
  @override bool get cacheFlag => false;
  @override Map<String, dynamic>? toRequestBody() => request.toJson();
  @override User parseResponse(Map<String, dynamic> responseData) => User.fromJson({});
}

class MyAuthProvider implements AuthTokenProvider {
  @override Future<String?> getAccessToken() async => 'token';
  @override Future<String?> refreshToken() async => 'new_token';
  @override Future<void> onAuthFailure() async {}
}