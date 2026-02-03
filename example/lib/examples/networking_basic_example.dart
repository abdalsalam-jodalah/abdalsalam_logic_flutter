// lib/examples/networking_basic_example.dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

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
  bool get queueFlag => true;

  @override
  int get priority => 0;

  @override
  bool get cacheFlag => true;

  @override
  Map<String, dynamic>? toRequestBody() => null;

  @override
  User parseResponse(Map<String, dynamic> responseData) {
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
  bool get needAuth => true;

  @override
  bool get queueFlag => true;

  @override
  int get priority => 1;

  @override
  bool get cacheFlag => false;

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

class NetworkingBasicExample {
  late NetworkRegistry _registry;
  late RequestManager _requestManager;
  late AppStateManager _appStateManager;

  Future<void> initialize() async {
    // Initialize required services
    _registry = NetworkRegistryImpl();
    _appStateManager = AppStateManagerImpl.create();
    _requestManager = RequestManagerImpl(
      registry: _registry,
      appStateManager: _appStateManager,
    );

    await _registry.initialize();
    await _appStateManager.initialize();
    await _requestManager.initialize();

    // Register APIs
    _registry.register(GetUserApi(1));
    _registry.register(CreateUserApi(CreateUserRequest(
      name: 'John Doe',
      email: 'john@example.com',
    )));
  }

  Future<void> demonstrateBasicUsage() async {
    print('=== Basic Networking Example ===\n');

    try {
      // Example 1: Get user
      print('1. Getting user...');
      final getUserApi = GetUserApi(1);
      final userResponse = await _requestManager.execute(getUserApi);
      
      if (userResponse.isSuccess) {
        print('✓ User retrieved: ${userResponse.parsedModel?.name}');
      } else {
        print('✗ Failed to get user: ${userResponse.error}');
      }

      // Example 2: Create user
      print('\n2. Creating user...');
      final createUserApi = CreateUserApi(CreateUserRequest(
        name: 'Jane Doe',
        email: 'jane@example.com',
      ));
      final createResponse = await _requestManager.execute(createUserApi);
      
      if (createResponse.isSuccess) {
        print('✓ User created: ${createResponse.parsedModel?.name}');
      } else {
        print('✗ Failed to create user: ${createResponse.error}');
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> dispose() async {
    await _requestManager.dispose();
    await _appStateManager.dispose();
    await _registry.dispose();
  }
}