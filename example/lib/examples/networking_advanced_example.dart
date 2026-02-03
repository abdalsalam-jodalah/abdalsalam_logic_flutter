// lib/examples/networking_advanced_example.dart
import 'dart:async';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class AuthTokenProviderImpl implements AuthTokenProvider {
  String? _accessToken;
  String? _refreshToken;

  AuthTokenProviderImpl({String? accessToken, String? refreshToken})
      : _accessToken = accessToken,
        _refreshToken = refreshToken;

  // Setters for demo purposes
  set accessToken(String? token) => _accessToken = token;
  set refreshTokenValue(String? token) => _refreshToken = token;

  @override
  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  @override
  Future<String?> refreshToken() async {
    if (_refreshToken == null) return null;
    
    // Simulate refresh token API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In real app, make API call to refresh token
    _accessToken = 'new_access_token_${DateTime.now().millisecondsSinceEpoch}';
    return _accessToken;
  }

  @override
  Future<void> onAuthFailure() async {
    _accessToken = null;
    _refreshToken = null;
    print('🔐 Authentication failed - tokens cleared');
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      userId: json['user_id'] as String,
    );
  }
}

class Profile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}

class LoginApi extends NetworkApi<LoginRequest, LoginResponse> {
  final LoginRequest request;

  LoginApi(this.request);

  @override
  String get apiTypeIdentifier => 'login';

  @override
  HttpMethod get method => HttpMethod.post;

  @override
  ApiUrl get urlObject => const ApiUrl(
        baseUrl: 'https://api.example.com',
        path: '/auth/login',
      );

  @override
  LoginRequest get bodyModel => request;

  @override
  bool get needAuth => false;

  @override
  bool get queueFlag => false; // Don't queue login requests

  @override
  int get priority => 10; // High priority

  @override
  bool get cacheFlag => false;

  @override
  Map<String, dynamic> toRequestBody() => request.toJson();

  @override
  LoginResponse parseResponse(Map<String, dynamic> responseData) {
    return LoginResponse.fromJson(responseData);
  }
}

class GetProfileApi extends NetworkApi<void, Profile> {
  @override
  String get apiTypeIdentifier => 'get_profile';

  @override
  HttpMethod get method => HttpMethod.get;

  @override
  ApiUrl get urlObject => const ApiUrl(
        baseUrl: 'https://api.example.com',
        path: '/user/profile',
      );

  @override
  void get bodyModel => null;

  @override
  bool get needAuth => true; // Requires authentication

  @override
  bool get queueFlag => true; // Queue when offline

  @override
  int get priority => 1;

  @override
  bool get cacheFlag => true;

  @override
  Map<String, dynamic>? toRequestBody() => null;

  @override
  Profile parseResponse(Map<String, dynamic> responseData) {
    return Profile.fromJson(responseData);
  }
}

class NetworkingAdvancedExample {
  late NetworkRegistry _registry;
  late RequestManager _requestManager;
  late AppStateManager _appStateManager;
  late AuthTokenProviderImpl _authTokenProvider;
  
  StreamSubscription<int>? _queueSubscription;

  Future<void> initialize() async {
    // Initialize auth provider
    _authTokenProvider = AuthTokenProviderImpl();

    // Initialize services with auth
    _registry = NetworkRegistryImpl();
    _appStateManager = AppStateManagerImpl.create();
    _requestManager = RequestManagerImpl(
      registry: _registry,
      appStateManager: _appStateManager,
      authTokenProvider: _authTokenProvider,
      statusCodeStrategy: InternalStatusCodeStrategy(
        statusField: 'status',
        messageField: 'message',
        successStatuses: ['success', 'ok'],
      ),
    );

    await _registry.initialize();
    await _appStateManager.initialize();
    await _requestManager.initialize();

    // Register APIs
    _registry.register(LoginApi(LoginRequest(
      email: 'user@example.com',
      password: 'password123',
    )));
    _registry.register(GetProfileApi());

    // Listen to queue changes
    _queueSubscription = _requestManager.queueCountStream.listen((count) {
      print('📊 Queue count: $count');
    });
  }

  Future<void> demonstrateAdvancedFeatures() async {
    print('=== Advanced Networking Example ===\n');

    try {
      // Example 1: Login to get tokens
      print('1. Logging in...');
      final loginApi = LoginApi(LoginRequest(
        email: 'user@example.com',
        password: 'password123',
      ));
      
      final loginResponse = await _requestManager.execute(loginApi);
      
      if (loginResponse.isSuccess && loginResponse.parsedModel != null) {
        print('✓ Login successful');
        
        // Update auth provider with new tokens
        _authTokenProvider._accessToken = loginResponse.parsedModel!.accessToken;
        _authTokenProvider._refreshToken = loginResponse.parsedModel!.refreshToken;
      } else {
        print('✗ Login failed: ${loginResponse.error}');
        return;
      }

      // Example 2: Get authenticated profile
      print('\n2. Getting user profile (requires auth)...');
      final profileApi = GetProfileApi();
      final profileResponse = await _requestManager.execute(profileApi);
      
      if (profileResponse.isSuccess) {
        print('✓ Profile retrieved: ${profileResponse.parsedModel?.name}');
      } else {
        print('✗ Profile failed: ${profileResponse.error}');
      }

      // Example 3: Test offline queue
      print('\n3. Testing offline queue...');
      _requestManager.disable();
      print('📵 Request manager disabled (simulating offline)');
      
      final offlineProfileApi = GetProfileApi();
      final offlineResponse = await _requestManager.execute(offlineProfileApi);
      
      if (!offlineResponse.isSuccess) {
        print('✓ Request queued for later: ${offlineResponse.error}');
      }
      
      // Re-enable and process queue
      print('\n4. Re-enabling and processing queue...');
      _requestManager.enable();
      await _requestManager.processQueue();
      print('✓ Queue processed');

      // Example 4: Show queue statistics
      final queueCount = await _requestManager.getPendingCount();
      print('\n📊 Final queue count: $queueCount');

    } catch (e) {
      if (e is NetworkAuthFailedException) {
        print('🔐 Auth error: ${e.message}');
      } else if (e is NetworkManagerDisabledException) {
        print('📵 Manager disabled: ${e.message}');
      } else if (e is NetworkUnregisteredApiException) {
        print('📋 Unregistered API: ${e.message}');
      } else {
        print('❌ Unexpected error: $e');
      }
    }
  }

  Future<void> dispose() async {
    await _queueSubscription?.cancel();
    await _requestManager.dispose();
    await _appStateManager.dispose();
    await _registry.dispose();
  }
}